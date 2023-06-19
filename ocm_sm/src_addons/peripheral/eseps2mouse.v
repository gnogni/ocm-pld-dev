//
// eseps2mouse.v
//   PS/2 keyboard interface for OCM-PLD/OCM-Kai
//   Revision 2.00
//
// Copyright (c) 2022 Takayuki Hara (HRA!)
// All rights reserved.
//
// Redistribution and use of this source code or any derivative works, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Redistributions may not be sold, nor may they be used in a commercial
//    product or activity without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//------------------------------------------------------------------------------
// Update note 更新履歴
//------------------------------------------------------------------------------
// MMM-DD-YYYY Rev.   Information
// Dec-15-2022 1.00 - First release by t.hara
//------------------------------------------------------------------------------

module eseps2mouse (
    input           clk21m,
    input           reset,
    input           clkena,

    //  board ports
    inout           pPs2Clk,
    inout           pPs2Dat,

    input   [5:0]   pJoyA_in,
    output  [1:0]   pJoyA_out,
    output          pStrA,

    //  internal signals
    output  [5:0]   pJoyA_in_m,
    input   [1:0]   pJoyA_out_m,
    input           pStrA_m,

    //  information
    input   [7:0]   pLed,

    input           pLedPwr,
    input   [1:0]   Slt2Mode,
    input   [1:0]   Slt1Type,
    input   [2:0]   MstrVol,

    input   [2:0]   OpllVol,
    input   [2:0]   PsgVol,
    input           tMegaSD,
    input           tPanaRedir,

    input   [2:0]   SccVol,
    input           VdpSpeedMode,
    input   [3:0]   CustomSpeed,

    input           Af_mask,
    input           V9938_n,
    input           swioKmap,
    input           caps,
    input           kana,
    input           iPsg2_ena,
    input   [1:0]   vga_scanlines,

    input           clksel,
    input           extclk3m,
    input           ntsc_pal_type,
    input           forced_v_mode,
    input           swioCmt,
    input           iSlt1_linear,
    input           iSlt2_linear,
    input           right_inverse,

    input           clksel5m_n
);
    reg     [18:0]  ff_timer;
    wire            w_timeout;
    reg     [7:0]   ff_ps2_rcv_dat;
    reg             ff_ps2_send;
    reg             ff_error;
    reg     [1:0]   ff_ps2_clk_count;
    reg             ff_ps2_clk_latch;
    reg             ff_ps2_clk_delay;
    reg     [4:0]   ff_ps2_state;
    reg     [4:0]   ff_ps2_sub_state;
    wire            w_ps2_rise_edge;
    wire            w_ps2_fall_edge;
    reg             ff_ps2_dat;
    reg     [7:0]   ff_ps2_snd_dat;
    reg             ff_ps2m_active;
    reg             ff_indicator;
    reg             ff_connected;
    reg     [1:0]   ff_button;              //  bit0: left button, bit1: right button. (0=release, 1=pressed)
    reg     [7:0]   ff_x;
    reg     [7:0]   ff_y;
    reg             ff_pStrA_m;
    wire            w_strobe_edge;
    reg     [2:0]   ff_mouse_state;
    reg     [5:0]   ff_mouse_out;
    reg     [10:0]  ff_mouse_timer;
    wire    [8:0]   w_x;
    wire    [8:0]   w_y;

    localparam      MST_IDLE        = 3'd0;
    localparam      MST_X_MSB       = 3'd1;
    localparam      MST_X_LSB       = 3'd2;
    localparam      MST_Y_MSB       = 3'd3;
    localparam      MST_Y_LSB       = 3'd4;
    localparam      MST_DUMMY       = 3'd5;

    localparam      PS2_ST_RESET                = 5'd0;
    localparam      PS2_ST_SND_RESET            = 5'd1;
    localparam      PS2_ST_RCV_ACK1             = 5'd2;
    localparam      PS2_ST_RCV_BATCMP           = 5'd3;
    localparam      PS2_ST_RCV_MOUSE_ID1        = 5'd4;
    localparam      PS2_ST_SND_SET_SAMPLE_RATE1 = 5'd5;
    localparam      PS2_ST_RCV_ACK2             = 5'd6;
    localparam      PS2_ST_SND_DECIMAL_40       = 5'd7;
    localparam      PS2_ST_RCV_ACK3             = 5'd8;
    localparam      PS2_ST_SND_DATA_READ        = 5'd9;
    localparam      PS2_ST_RCV_ACK4             = 5'd10;
    localparam      PS2_ST_RCV_BUTTON           = 5'd11;
    localparam      PS2_ST_RCV_X                = 5'd12;
    localparam      PS2_ST_RCV_Y                = 5'd13;
    localparam      PS2_ST_SND_LENGTH           = 5'd14;
    localparam      PS2_ST_SND_DATA1            = 5'd15;
    localparam      PS2_ST_SND_DATA2            = 5'd16;
    localparam      PS2_ST_SND_DATA3            = 5'd17;
    localparam      PS2_ST_SND_DATA4            = 5'd18;
    localparam      PS2_ST_SND_DATA5            = 5'd19;
    localparam      PS2_ST_SND_DATA6            = 5'd20;
    localparam      PS2_ST_SND_DATA7            = 5'd21;
    localparam      PS2_ST_LOAD                 = 5'd22;
    localparam      PS2_ST_NEXT                 = 5'd23;

    localparam      PS2_SUB_IDLE            = 5'd0;
    localparam      PS2_SUB_RCV_START       = 5'd1;
    localparam      PS2_SUB_RCV_D0          = 5'd2;
    localparam      PS2_SUB_RCV_D1          = 5'd3;
    localparam      PS2_SUB_RCV_D2          = 5'd4;
    localparam      PS2_SUB_RCV_D3          = 5'd5;
    localparam      PS2_SUB_RCV_D4          = 5'd6;
    localparam      PS2_SUB_RCV_D5          = 5'd7;
    localparam      PS2_SUB_RCV_D6          = 5'd8;
    localparam      PS2_SUB_RCV_D7          = 5'd9;
    localparam      PS2_SUB_RCV_PARITY      = 5'd10;
    localparam      PS2_SUB_RCV_STOP        = 5'd11;
    localparam      PS2_SUB_SND_REQUEST     = 5'd12;
    localparam      PS2_SUB_SND_START       = 5'd13;
    localparam      PS2_SUB_SND_D0          = 5'd14;
    localparam      PS2_SUB_SND_D1          = 5'd15;
    localparam      PS2_SUB_SND_D2          = 5'd16;
    localparam      PS2_SUB_SND_D3          = 5'd17;
    localparam      PS2_SUB_SND_D4          = 5'd18;
    localparam      PS2_SUB_SND_D5          = 5'd19;
    localparam      PS2_SUB_SND_D6          = 5'd20;
    localparam      PS2_SUB_SND_D7          = 5'd21;
    localparam      PS2_SUB_SND_PARITY      = 5'd22;
    localparam      PS2_SUB_SND_STOP        = 5'd23;
    localparam      PS2_SUB_SND_ACK         = 5'd24;
    localparam      PS2_SUB_WAIT            = 5'd25;

    // ------------------------------------------------------------------------
    //  PS2 State Machine
    // ------------------------------------------------------------------------
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_clk_count <= 2'd0;
        end
        else if( clkena ) begin
            if(      pPs2Clk == 1'b0 && ff_ps2_clk_count != 2'd0 ) begin
                ff_ps2_clk_count <= ff_ps2_clk_count - 2'd1;
            end
            else if( pPs2Clk == 1'b1 && ff_ps2_clk_count != 2'd3 ) begin
                ff_ps2_clk_count <= ff_ps2_clk_count + 2'd1;
            end
            else begin
                //  hold
            end
        end
        else begin
            //  hold
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_clk_latch    <= 1'b0;
            ff_ps2_clk_delay    <= 1'b0;
        end
        else if( clkena ) begin
            if( ff_ps2_clk_count == 2'd0 ) begin
                ff_ps2_clk_latch <= 1'b0;
            end
            else if( ff_ps2_clk_count == 2'd3 ) begin
                ff_ps2_clk_latch <= 1'b1;
            end
            else begin
                //  hold
            end
            ff_ps2_clk_delay <= ff_ps2_clk_latch;
        end
        else begin
            //  hold
        end
    end

    assign w_ps2_rise_edge      = ( ff_ps2_clk_delay == 1'b0 && ff_ps2_clk_latch == 1'b1 ) ? 1'b1 : 1'b0;
    assign w_ps2_fall_edge      = ( ff_ps2_clk_delay == 1'b1 && ff_ps2_clk_latch == 1'b0 ) ? 1'b1 : 1'b0;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_state    <= PS2_ST_RESET;
            ff_ps2_send     <= 1'b0;
            ff_ps2m_active  <= 1'b0;
            ff_connected    <= 1'b0;
            ff_indicator    <= 1'b0;
        end
        else if( clkena ) begin
            if( w_timeout && ff_ps2_state != PS2_ST_RESET && ff_ps2_state != PS2_ST_SND_RESET && ff_ps2_state != PS2_ST_NEXT && ff_ps2_sub_state != PS2_SUB_SND_REQUEST ) begin
                //  for illegal keyboard
                ff_ps2_state    <= PS2_ST_SND_RESET;
            end
            else begin
                case( ff_ps2_state )
                PS2_ST_RESET:
                    begin
                        if( w_timeout ) begin
                            ff_ps2_state    <= PS2_ST_SND_RESET;
                            ff_ps2_send     <= 1'b1;
                        end
                        else begin
                            ff_ps2m_active  <= 1'b0;
                            ff_indicator    <= 1'b0;
                        end
                    end
                PS2_ST_SND_RESET, PS2_ST_SND_SET_SAMPLE_RATE1, PS2_ST_SND_DECIMAL_40, PS2_ST_SND_DATA_READ, PS2_ST_SND_DATA7:
                    begin
                        if( ff_error ) begin
                            //  reset command error
                            ff_ps2_state    <= PS2_ST_SND_RESET;
                            ff_ps2_send     <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= ff_ps2_state + 5'd1;
                            ff_ps2_send     <= 1'b0;
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                PS2_ST_SND_LENGTH, PS2_ST_SND_DATA1, PS2_ST_SND_DATA2, PS2_ST_SND_DATA3, PS2_ST_SND_DATA4, PS2_ST_SND_DATA5, PS2_ST_SND_DATA6:
                    begin
                        if( ff_error ) begin
                            //  reset command error
                            ff_ps2_state    <= PS2_ST_SND_RESET;
                            ff_ps2_send     <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= ff_ps2_state + 5'd1;
                            ff_ps2_send     <= 1'b1;
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                PS2_ST_RCV_ACK1, PS2_ST_RCV_ACK4:
                    begin
                        if( ff_error ) begin
                            //  for illegal keyboard
                            ff_ps2_state    <= PS2_ST_SND_RESET;
                            ff_ps2_send     <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hFA ) begin
                                ff_ps2_state    <= ff_ps2_state + 5'd1;
                                ff_ps2_send     <= 1'b0;
                            end
                            else begin
                                //  reset command error
                                ff_ps2_state    <= PS2_ST_SND_RESET;
                                ff_ps2_send     <= 1'b1;
                            end
                        end
                    end
                PS2_ST_RCV_ACK2, PS2_ST_RCV_ACK3:
                    begin
                        if( ff_error ) begin
                            //  for illegal keyboard
                            ff_ps2_state    <= PS2_ST_SND_RESET;
                            ff_ps2_send     <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hFA ) begin
                                ff_ps2_state    <= ff_ps2_state + 5'd1;
                                ff_ps2_send     <= 1'b1;
                            end
                            else begin
                                //  reset command error
                                ff_ps2_state    <= PS2_ST_SND_RESET;
                                ff_ps2_send     <= 1'b1;
                            end
                        end
                    end
                PS2_ST_RCV_BATCMP:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hAA ) begin
                                ff_ps2_state    <= PS2_ST_RCV_MOUSE_ID1;
                                ff_ps2m_active  <= 1'b1;
                            end
                            else begin
                                //  for illegal keyboard
                                ff_ps2_state    <= PS2_ST_SND_RESET;
                                ff_ps2_send     <= 1'b1;
                            end
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                PS2_ST_RCV_MOUSE_ID1:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'h00 ) begin
                                ff_indicator    <= 1'b0;
                                ff_ps2_state    <= ff_ps2_state + 5'd1;
                                ff_ps2_send     <= 1'b1;
                            end
                            else if( ff_ps2_rcv_dat == 8'h10 ) begin
                                ff_indicator    <= 1'b1;
                                ff_ps2_state    <= ff_ps2_state + 5'd1;
                                ff_ps2_send     <= 1'b1;
                            end
                            else begin
                                //  for illegal keyboard
                                ff_ps2_state    <= PS2_ST_SND_RESET;
                                ff_ps2_send     <= 1'b1;
                            end
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                PS2_ST_RCV_BUTTON:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_button       <= ~ff_ps2_rcv_dat[1:0];
                            ff_connected    <= ff_ps2_rcv_dat[3] | ~ff_indicator;
                            ff_ps2_state    <= PS2_ST_RCV_X;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_ST_RCV_X:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= PS2_ST_RCV_Y;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_ST_RCV_Y:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_indicator ) begin
                                ff_ps2_state    <= PS2_ST_SND_LENGTH;
                                ff_ps2_send     <= 1'b1;
                            end
                            else begin
                                ff_ps2_state    <= PS2_ST_LOAD;
                            end
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_ST_LOAD:
                    begin
                        ff_ps2_state    <= PS2_ST_NEXT;
                    end
                PS2_ST_NEXT:
                    begin
                        if( w_timeout ) begin
                            ff_ps2_state    <= PS2_ST_SND_DATA_READ;
                            ff_ps2_send     <= 1'b1;
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                default:
                    begin
                        ff_ps2_state    <= PS2_ST_RESET;
                        ff_ps2_send     <= 1'b0;
                    end
                endcase
            end
        end
    end

    assign w_x  = { ff_x[7], ff_x } - { ff_ps2_rcv_dat[7], ff_ps2_rcv_dat };
    assign w_y  = { ff_y[7], ff_y } + { ff_ps2_rcv_dat[7], ff_ps2_rcv_dat };

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_x <= 8'd0;
            ff_y <= 8'd0;
        end
        else if( clkena ) begin
            if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                begin
                    if( ff_ps2_state == PS2_ST_RCV_X ) begin
                        if( w_x[8:7] == 2'b10 ) begin
                            ff_x <= 8'b10000000;
                        end
                        else if( w_x[8:7] == 2'b01 ) begin
                            ff_x <= 8'b01111111;
                        end
                        else begin
                            ff_x    <= w_x[7:0];
                        end
                    end
                    else if( ff_ps2_state == PS2_ST_RCV_Y ) begin
                        if( w_y[8:7] == 2'b10 ) begin
                            ff_y <= 8'b10000000;
                        end
                        else if( w_y[8:7] == 2'b01 ) begin
                            ff_y <= 8'b01111111;
                        end
                        else begin
                            ff_y    <= w_y[7:0];
                        end
                    end
                end
            end
        end
        else if( ff_mouse_state == MST_DUMMY && (w_strobe_edge || (ff_mouse_timer == 11'd0)) ) begin
            ff_x <= 8'd0;
            ff_y <= 8'd0;
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_sub_state    <= PS2_SUB_IDLE;
            ff_error            <= 1'b0;
        end
        else if( clkena ) begin
            if( ff_ps2_state == PS2_ST_RESET ) begin
                ff_ps2_sub_state    <= PS2_SUB_IDLE;
            end
            else begin
                case( ff_ps2_sub_state )
                PS2_SUB_IDLE:
                    begin
                        if( ff_ps2_send ) begin
                            ff_ps2_sub_state    <= PS2_SUB_SND_REQUEST;
                        end
                        else if( w_ps2_fall_edge ) begin
                            ff_ps2_sub_state    <= PS2_SUB_RCV_START;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_SUB_RCV_START,
                PS2_SUB_RCV_D0, PS2_SUB_RCV_D1, PS2_SUB_RCV_D2, PS2_SUB_RCV_D3,
                PS2_SUB_RCV_D4, PS2_SUB_RCV_D5, PS2_SUB_RCV_D6, PS2_SUB_RCV_D7,
                PS2_SUB_RCV_PARITY:
                    begin
                        if( w_ps2_fall_edge ) begin
                            ff_ps2_sub_state <= ff_ps2_sub_state + 5'd1;
                        end
                        else if( w_timeout ) begin
                            ff_ps2_sub_state    <= PS2_SUB_WAIT;
                            ff_error            <= 1'b1;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_SUB_RCV_STOP:
                    begin
                        if( w_ps2_rise_edge ) begin
                            ff_ps2_sub_state <= PS2_SUB_WAIT;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_SUB_SND_REQUEST:
                    begin
                        if( w_timeout ) begin
                            ff_ps2_sub_state <= PS2_SUB_SND_START;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_SUB_SND_START,
                PS2_SUB_SND_D0, PS2_SUB_SND_D1, PS2_SUB_SND_D2, PS2_SUB_SND_D3,
                PS2_SUB_SND_D4, PS2_SUB_SND_D5, PS2_SUB_SND_D6, PS2_SUB_SND_D7,
                PS2_SUB_SND_PARITY, PS2_SUB_SND_STOP:
                    begin
                        if( w_ps2_fall_edge ) begin
                            ff_ps2_sub_state <= ff_ps2_sub_state + 5'd1;
                        end
                        else if( w_timeout ) begin
                            ff_ps2_sub_state    <= PS2_SUB_WAIT;
                            ff_error            <= 1'b1;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_SUB_SND_ACK:
                    begin
                        ff_ps2_sub_state <= PS2_SUB_WAIT;
                    end
                PS2_SUB_WAIT:
                    begin
                        ff_ps2_sub_state    <= PS2_SUB_IDLE;
                        ff_error            <= 1'b0;
                    end
                default:
                    ff_ps2_sub_state    <= PS2_SUB_IDLE;
                endcase
            end
        end
    end

    // ------------------------------------------------------------------------
    //  Timer
    // ------------------------------------------------------------------------
    localparam      TIMER_M36USEC = 19'd384;        //  0.2794usec * 128clock       = 35.7632usec (512 - 128 clock)
    localparam      TIMER_286USEC = 19'd1024;       //  0.2794usec * 1024clock      = 286.106usec (PS/2 spec. minimum 100usec)
    localparam      TIMER_12MSEC = 19'd42949;       //  0.2794usec * 42949clock     = 12msec
    localparam      TIMER_20MSEC = 19'd71582;       //  0.2794usec * 71582clock     = 20msec
    localparam      TIMER_120MSEC = 19'd429492;     //  0.2794usec * 429492clock    = 120msec

    assign w_timeout    = (ff_timer == 19'h00000) ? 1'b1 : 1'b0;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_timer <= TIMER_120MSEC;
        end
        else if( clkena ) begin
            if( ff_ps2_state == PS2_ST_NEXT ) begin
                if( w_timeout ) begin
                    ff_timer <= TIMER_12MSEC;
                end
                else begin
                    ff_timer <= ff_timer - 19'd1;
                end
            end
            else if( w_timeout && (ff_ps2_state == PS2_ST_RESET || ff_ps2_state == PS2_ST_SND_RESET) ) begin
                ff_timer <= TIMER_120MSEC;
            end
            else if( ff_ps2_state == PS2_ST_LOAD ) begin
                ff_timer <= TIMER_12MSEC;
            end
            else if( w_timeout && ff_ps2_sub_state == PS2_SUB_SND_REQUEST ) begin
                ff_timer <= TIMER_12MSEC;
            end
            else if( w_ps2_rise_edge && (
                    ff_ps2_sub_state == PS2_SUB_SND_D0 || ff_ps2_sub_state == PS2_SUB_SND_D1 ||
                    ff_ps2_sub_state == PS2_SUB_SND_D2 || ff_ps2_sub_state == PS2_SUB_SND_D3 ||
                    ff_ps2_sub_state == PS2_SUB_SND_D4 || ff_ps2_sub_state == PS2_SUB_SND_D5 ||
                    ff_ps2_sub_state == PS2_SUB_SND_D6 || ff_ps2_sub_state == PS2_SUB_SND_D7 ||
                    ff_ps2_sub_state == PS2_SUB_SND_PARITY ) ) begin
                ff_timer <= TIMER_286USEC;
            end
            else if( w_ps2_fall_edge && (
                    ff_ps2_sub_state == PS2_SUB_RCV_START ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D0 || ff_ps2_sub_state == PS2_SUB_RCV_D1 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D2 || ff_ps2_sub_state == PS2_SUB_RCV_D3 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D4 || ff_ps2_sub_state == PS2_SUB_RCV_D5 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D6 || ff_ps2_sub_state == PS2_SUB_RCV_D7 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_PARITY ) ) begin
                ff_timer <= TIMER_286USEC;
            end
            else if( ff_ps2_state != PS2_ST_RESET && ff_ps2_sub_state == PS2_SUB_IDLE ) begin
                if( ff_error ) begin
                    ff_timer <= TIMER_20MSEC;
                end
                if( ff_ps2_send ) begin
                    ff_timer <= TIMER_286USEC;
                end
                else begin
                    ff_timer <= TIMER_20MSEC;
                end
            end
            else if( !w_timeout ) begin
                ff_timer <= ff_timer - 19'd1;
            end
            else begin
                //  hold
            end
        end
    end

    // ------------------------------------------------------------------------
    //  PS2 Clock
    // ------------------------------------------------------------------------
    reg         ff_ps2_clk;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            //  This must be set to 1'bZ. This is because setting it to 1'b0 will make the G300 unstable.
            ff_ps2_clk <= 1'bZ;
        end
        else if( clkena ) begin
            if( ff_ps2_state == PS2_ST_RESET  ) begin
                //  This must be set to 1'bZ. This is because setting it to 1'b0 will make the G300 unstable.
                ff_ps2_clk <= 1'bZ;
            end
            else if( (ff_ps2_sub_state == PS2_SUB_SND_REQUEST) || (ff_ps2_state == PS2_ST_SND_RESET && ff_ps2_sub_state == PS2_SUB_IDLE) ) begin
                ff_ps2_clk <= 1'b0;
            end
            else begin
                ff_ps2_clk <= 1'bZ;
            end
        end
    end

    assign pPs2Clk  = ff_ps2_clk;

    // ------------------------------------------------------------------------
    //  PS2 Data (Sender)
    // ------------------------------------------------------------------------
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_dat <= 1'bZ;
        end
        else if( clkena ) begin
            if( ff_ps2_sub_state == PS2_ST_RESET || ff_ps2_sub_state == PS2_SUB_IDLE ) begin
                ff_ps2_dat <= 1'bZ;
            end
            else if( ff_timer == TIMER_M36USEC && ff_ps2_sub_state == PS2_SUB_SND_REQUEST ) begin
                ff_ps2_dat <= 1'b0;
            end
            else if( w_ps2_fall_edge ) begin
                case( ff_ps2_sub_state )
                PS2_SUB_SND_START, PS2_SUB_SND_D0, PS2_SUB_SND_D1, PS2_SUB_SND_D2, PS2_SUB_SND_D3,
                PS2_SUB_SND_D4, PS2_SUB_SND_D5, PS2_SUB_SND_D6:
                                        ff_ps2_dat <= ff_ps2_snd_dat[0]    ? 1'bZ : 1'b0;
                PS2_SUB_SND_D7:         ff_ps2_dat <= (~(^ff_ps2_snd_dat)) ? 1'bZ : 1'b0;
                default:                ff_ps2_dat <= 1'bZ;
                endcase
            end
            else if( w_ps2_rise_edge ) begin
                if( ff_ps2_sub_state == PS2_SUB_SND_STOP ) begin
                    ff_ps2_dat <= 1'bZ;
                end
            end
        end
    end

    always @( posedge clk21m ) begin
        if( clkena ) begin
            if( ff_ps2_sub_state == PS2_SUB_SND_REQUEST ) begin
                case( ff_ps2_state )
                PS2_ST_SND_RESET:
                    ff_ps2_snd_dat <= 8'hFF;
                PS2_ST_SND_SET_SAMPLE_RATE1:
                    ff_ps2_snd_dat <= 8'hF3;
                PS2_ST_SND_DECIMAL_40:
                    ff_ps2_snd_dat <= 8'd40;
                PS2_ST_SND_DATA_READ:
                    ff_ps2_snd_dat <= 8'hEB;
                PS2_ST_SND_LENGTH:
                    ff_ps2_snd_dat <= 8'd7;
                PS2_ST_SND_DATA1:
                    ff_ps2_snd_dat <= pLed;
                PS2_ST_SND_DATA2:
                    ff_ps2_snd_dat <= { pLedPwr, Slt2Mode, Slt1Type, MstrVol };
                PS2_ST_SND_DATA3:
                    ff_ps2_snd_dat <= { OpllVol, PsgVol, tMegaSD, tPanaRedir };
                PS2_ST_SND_DATA4:
                    ff_ps2_snd_dat <= { SccVol, VdpSpeedMode, CustomSpeed };
                PS2_ST_SND_DATA5:
                    ff_ps2_snd_dat <= { Af_mask, V9938_n, swioKmap, caps, kana, iPsg2_ena, vga_scanlines };
                PS2_ST_SND_DATA6:
                    ff_ps2_snd_dat <= { clksel, extclk3m, ntsc_pal_type, forced_v_mode, swioCmt, iSlt1_linear, iSlt2_linear, right_inverse };
                PS2_ST_SND_DATA7:
                    ff_ps2_snd_dat <= { 7'd0, clksel5m_n };
                default:
                    begin
                        //  hold
                    end
                endcase
            end
            else if( ff_ps2_sub_state >= PS2_SUB_SND_START && ff_ps2_sub_state <= PS2_SUB_SND_D6 ) begin
                if( w_ps2_fall_edge ) begin
                    ff_ps2_snd_dat <= { ff_ps2_snd_dat[0], ff_ps2_snd_dat[7:1] };
                end
            end
            else begin
                //  hold
            end
        end
    end

    assign pPs2Dat  = ff_ps2_dat;

    // ------------------------------------------------------------------------
    //  PS2 Data (Receiver)
    // ------------------------------------------------------------------------
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_rcv_dat <= 8'h00;
        end
        else if( clkena ) begin
            if( w_ps2_fall_edge ) begin
                case( ff_ps2_sub_state )
                PS2_SUB_RCV_START,
                PS2_SUB_RCV_D0, PS2_SUB_RCV_D1, PS2_SUB_RCV_D2, PS2_SUB_RCV_D3,
                PS2_SUB_RCV_D4, PS2_SUB_RCV_D5, PS2_SUB_RCV_D6:
                    begin
                        ff_ps2_rcv_dat <= { pPs2Dat, ff_ps2_rcv_dat[7:1] };
                    end
                default:
                    begin
                        //  hold
                    end
                endcase
            end
        end
    end

    // ------------------------------------------------------------------------
    //  MSX mouse emulation
    // ------------------------------------------------------------------------
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_pStrA_m <= 1'b0;
        end
        else if( clkena ) begin
            ff_pStrA_m <= pStrA_m;
        end
    end

    assign w_strobe_edge    = pStrA_m ^ ff_pStrA_m;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_mouse_timer <= 11'd0;
        end
        else if( clkena ) begin
            if( w_strobe_edge ) begin
                ff_mouse_timer <= 11'd2047;
            end
            else if( ff_mouse_timer ) begin
                ff_mouse_timer <= ff_mouse_timer - 11'd1;
            end
            else begin
                //  hold
            end
        end
        else begin
            //  hold
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_mouse_state <= 3'd0;
        end
        else if( clkena ) begin
            if( w_strobe_edge ) begin
                if( ff_mouse_state == MST_DUMMY ) begin
                    ff_mouse_state <= MST_IDLE;
                end
                else begin
                    ff_mouse_state <= ff_mouse_state + 3'd1;
                end
            end
            else if( ff_mouse_timer == 11'd0 ) begin
                ff_mouse_state <= MST_IDLE;
            end
            else begin
                //  hold
            end
        end
        else begin
            //  hold
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_mouse_out <= 6'd0;
        end
        else begin
            case( ff_mouse_state )
            MST_X_MSB:  ff_mouse_out <= { ff_button, ff_x[7:4] };
            MST_X_LSB:  ff_mouse_out <= { ff_button, ff_x[3:0] };
            MST_Y_MSB:  ff_mouse_out <= { ff_button, ff_y[7:4] };
            MST_Y_LSB:  ff_mouse_out <= { ff_button, ff_y[3:0] };
            default:    ff_mouse_out <= { ff_button, 4'b1111   };
            endcase
        end
    end

    assign pJoyA_in_m   = (ff_ps2m_active && ff_connected) ? ff_mouse_out : pJoyA_in;
    assign pJoyA_out    = pJoyA_out_m;
    assign pStrA        = pStrA_m;
endmodule
