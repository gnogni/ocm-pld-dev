--
-- scc_ram.vhd
--   256 bytes of block memory
--   Revision 1.00
--
-- Copyright (c) 2007 Takayuki Hara
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
-- modified by caro 19/03/2008
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity scc_ram is
    port (
        adr     : in    std_logic_vector( 7 downto 0 );
        clk     : in    std_logic;
        we      : in    std_logic;
        dbi     : in    std_logic_vector( 7 downto 0 );
        dbo1    : out   std_logic_vector( 7 downto 0 );
        dbo2    : out   std_logic_vector( 7 downto 0 )
    );
end scc_ram;

architecture rtl of scc_ram is
    type ramdb is array( 0 to 255 ) of std_logic_vector( 7 downto 0 );

    signal block_ram    : ramdb;
    signal block_ram1   : ramdb;    -- caro
    signal iadr         : std_logic_vector( 7 downto 0 );
    signal w_adr_p1     : std_logic_vector( 4 downto 0 );
begin

-- write
    process( clk )
    begin
        if( clk'event and clk ='1' )then
            if( we = '1' )then
                block_ram( conv_integer(adr) ) <= dbi;
                block_ram1( conv_integer(adr) ) <= dbi; -- caro
            end if;
        end if;
    end process;

-- read
    w_adr_p1 <= adr( 4 downto 0 ) + 1;
    process( clk )
    begin
        if( clk'event and clk ='1' )then
            dbo1 <= block_ram( conv_integer( adr ) );
            dbo2 <= block_ram1( conv_integer( adr( 7 downto 5 ) & w_adr_p1 ) ); -- caro
        end if;
    end process;
end rtl;
