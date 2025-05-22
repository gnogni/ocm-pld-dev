--
-- uart_lite.vhd
--   UART Minimal for MSX++
--   Revision 1.00
--
-- Copyright (c) 2025 KdL
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- Update history
--
-- 2025/May/22nd, KdL
--   First release.
--   Entity compatible with "UART - Victor Trucco".
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
    port(
        uart_prescaler_i    : in  std_logic_vector( 13 downto 0 );
        clock_i             : in  std_logic;
        TX_start_i          : in  std_logic;
        TX_byte_i           : in  std_logic_vector(  7 downto 0 );
        TX_active_o         : out std_logic;
        TX_out_o            : out std_logic;
        TX_byte_finished_o  : out std_logic;
        RX_in_i             : in  std_logic;
        RX_byte_finished_o  : out std_logic;
        RX_byte_o           : out std_logic_vector(  7 downto 0 )
    );
end UART;

architecture RTL of UART is
    -- Define simplified states for TX and RX state machines
    type tx_state_t is (TX_IDLE, TX_START, TX_DATA, TX_STOP);
    type rx_state_t is (RX_IDLE, RX_START, RX_DATA, RX_STOP);

    signal tx_state         : tx_state_t := TX_IDLE;
    signal rx_state         : rx_state_t := RX_IDLE;

    -- ticks_per_bit determines the number of clock cycles per bit period
    signal ticks_per_bit    : integer;

    -- TX signals
    signal tx_counter       : integer range 0 to 65535 := 0;
    signal tx_bit_index     : integer range 0 to 7 := 0;
    signal tx_buffer        : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_done          : std_logic := '0';

    -- RX signals
    signal rx_counter       : integer range 0 to 65535 := 0;
    signal rx_bit_index     : integer range 0 to 7 := 0;
    signal rx_buffer        : std_logic_vector(7 downto 0) := (others => '0');

    -- Single stage synchronizer for the incoming RX signal to reduce logic resources
    signal rx_sync          : std_logic := '1';
    signal rx_done          : std_logic := '0';

begin
    -- Convert the prescaler from a vector to an integer
    ticks_per_bit   <=  to_integer(unsigned(uart_prescaler_i));

    --------------------------------------------------------------------
    -- TX Lite => Minimal state machine for transmission
    --------------------------------------------------------------------
    process(clock_i)
    begin
        if rising_edge(clock_i) then
            case tx_state is
                when TX_IDLE =>
                    TX_out_o        <= '1';                             -- TX line idle high
                    tx_done         <= '0';
                    tx_counter      <= 0;
                    tx_bit_index    <= 0;
                    if TX_start_i = '1' then
                        tx_buffer   <= TX_byte_i;
                        tx_state    <= TX_START;
                    end if;

                when TX_START =>
                    TX_out_o        <= '0';                             -- Send start bit (logic 0)
                    if tx_counter < ticks_per_bit - 1 then
                        tx_counter  <= tx_counter + 1;
                    else
                        tx_counter  <= 0;
                        tx_state    <= TX_DATA;
                    end if;

                when TX_DATA =>
                    TX_out_o        <= tx_buffer(tx_bit_index);         -- Send data bits
                    if tx_counter < ticks_per_bit - 1 then
                        tx_counter  <= tx_counter + 1;
                    else
                        tx_counter  <= 0;
                        if tx_bit_index < 7 then
                            tx_bit_index    <= tx_bit_index + 1;
                        else
                            tx_bit_index <= 0;
                            tx_state        <= TX_STOP;
                        end if;
                    end if;

                when TX_STOP =>
                    TX_out_o        <= '1';                             -- Send stop bit (logic 1)
                    if tx_counter < ticks_per_bit - 1 then
                        tx_counter  <= tx_counter + 1;
                    else
                        tx_counter  <= 0;
                        tx_done     <= '1';
                        tx_state    <= TX_IDLE;
                    end if;
            end case;
        end if;
    end process;

    -- Output signals for TX
    TX_active_o         <= '1' when tx_state /= TX_IDLE else '0';
    TX_byte_finished_o  <= tx_done;

    --------------------------------------------------------------------
    -- RX Lite => Minimal state machine for reception
    --------------------------------------------------------------------
    process(clock_i)
    begin
        if rising_edge(clock_i) then
            -- Simple synchronizer for the incoming RX signal
            rx_sync <= RX_in_i;
            case rx_state is
                when RX_IDLE =>
                    rx_done         <= '0';
                    rx_counter      <= 0;
                    rx_bit_index    <= 0;
                    if rx_sync = '0' then                               -- Detect falling edge (start bit)
                        rx_state    <= RX_START;
                    end if;

                when RX_START =>
                    -- Sample at the middle of the start bit
                    if rx_counter < (ticks_per_bit / 2) - 1 then
                        rx_counter  <= rx_counter + 1;
                    else
                        rx_counter  <= 0;
                        if rx_sync = '0' then                           -- Confirm valid start bit
                            rx_state    <= RX_DATA;
                        else
                            rx_state    <= RX_IDLE;                     -- False start detected
                        end if;
                    end if;

                when RX_DATA =>
                    if rx_counter < ticks_per_bit - 1 then
                        rx_counter  <= rx_counter + 1;
                    else
                        rx_counter  <= 0;
                        rx_buffer(rx_bit_index) <= rx_sync;             -- Capture received bit
                        if rx_bit_index < 7 then
                            rx_bit_index    <= rx_bit_index + 1;
                        else
                            rx_bit_index    <= 0;
                            rx_state        <= RX_STOP;
                        end if;
                    end if;

                when RX_STOP =>
                    if rx_counter < ticks_per_bit - 1 then
                        rx_counter  <= rx_counter + 1;
                    else
                        rx_counter  <= 0;
                        rx_done     <= '1';
                        RX_byte_o   <= rx_buffer;
                        rx_state    <= RX_IDLE;
                    end if;
            end case;
        end if;
    end process;

    -- Output signal for RX
    RX_byte_finished_o <= rx_done;

end RTL;
