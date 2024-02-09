//
// sm_eseps2.v
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
// Update note
//------------------------------------------------------------------------------
// MMM-DD-YYYY Rev.   Information
// Apl-24-2022 2.00 - Newly redesigned by t.hara
// Oct-22-2022 2.01 - Modified signal timing by t.hara
//------------------------------------------------------------------------------

module eseps2 #(
    parameter       numlk_is_kana   = 1'b1,     //  NumLk LED mode      1'b0: NumLk, 1'b1: Kana
    parameter       numlk_initial   = 1'b1      //  NumLk initial value 1'b0: OFF  , 1'b1: ON
) (
    input           clk21m,
    input           reset,
    input           clkena,

    input           Kmap,

    input           Caps,
    input           Kana,
    output          Paus,       //  Pause
    output          Scro,       //  CMT Switch
    output          Reso,       //  Display Mode

    // | b7    | b6    | b5   | b4   | b3   | b2   | b1   | b0   |
    // | SHIFT | LCTRL | PgUp | PgDn | F9   | F10  | F11  | F12  |      0: unpressed, 1: pressed
    output  [7:0]   Fkeys,

    inout           pPs2Clk,
    inout           pPs2Dat,

    input   [7:0]   PpiPortC,
    output  [7:0]   pKeyX,

    input           CmtScro

//  output  [15:0]  debug_sig
);
    localparam      enable_debug    = 0;        //  0: release mode, 1: debug mode

    reg     [18:0]  ff_timer;
    wire            w_timeout;
    reg     [7:0]   ff_ps2_rcv_dat;
    reg             ff_f0_detect;
    reg             ff_e0_detect;
    reg             ff_e1_detect;
    reg             ff_ps2_send;
    reg             ff_ps2_virtual_shift;
    reg             ff_e0_detect_dl;
    reg             ff_error;
    reg             ff_no_send;
    reg     [1:0]   ff_ps2_clk_count;
    reg             ff_ps2_clk_latch;
    reg             ff_ps2_clk_delay;
    reg     [3:0]   ff_ps2_state;
    reg     [4:0]   ff_ps2_sub_state;
    wire            w_ps2_host_phase;
    wire            w_ps2_rise_edge;
    wire            w_ps2_fall_edge;
    wire            w_ps2_led_change;
    reg             ff_ps2_dat;
    reg     [7:0]   ff_ps2_snd_dat;

    localparam      PS2_ST_RESET        = 4'd0;
    localparam      PS2_ST_SND_RESET    = 4'd1;
    localparam      PS2_ST_RCV_ACK1     = 4'd2;
    localparam      PS2_ST_RCV_BATCMP   = 4'd3;
    localparam      PS2_ST_SND_SETMON   = 4'd4;
    localparam      PS2_ST_RCV_ACK3     = 4'd5;
    localparam      PS2_ST_SND_OPT      = 4'd6;
    localparam      PS2_ST_RCV_ACK4     = 4'd7;
    localparam      PS2_ST_IDLE         = 4'd8;
    localparam      PS2_ST_RCV_SCAN     = 4'd9;
    localparam      PS2_ST_RECOVERY     = 4'd10;

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

    localparam      MATUPD_ST_RESET             = 4'd0;
    localparam      MATUPD_ST_IDLE              = 4'd1;
    localparam      MATUPD_ST_KEYMAP_READ1      = 4'd2;
    localparam      MATUPD_ST_MATRIX_READ1_REQ  = 4'd3;
    localparam      MATUPD_ST_MATRIX_READ1_RES  = 4'd4;
    localparam      MATUPD_ST_MATRIX_WRITE1     = 4'd5;
    localparam      MATUPD_ST_KEYMAP_READ2      = 4'd6;
    localparam      MATUPD_ST_MATRIX_READ2_REQ  = 4'd7;
    localparam      MATUPD_ST_MATRIX_READ2_RES  = 4'd8;
    localparam      MATUPD_ST_MATRIX_WRITE2     = 4'd9;
    reg     [3:0]   ff_matupd_state;
    reg             ff_matupd_we;
    reg             ff_matupd_ppi_c;
    reg     [3:0]   ff_matupd_rows;
    reg     [7:0]   ff_matupd_keys;
    reg     [10:0]  ff_keymap_index;
    reg             ff_key_unpress;         //  0: pressed, 1: unpressed
    reg     [3:0]   ff_key_bits;
    wire    [7:0]   w_keymap_dat;
    reg     [7:0]   ff_key_x;
    wire    [7:0]   w_mask;
    wire    [7:0]   w_matrix_pre;
    wire    [7:0]   w_matrix;
    reg     [5:0]   ff_func_keys;

    // --------------------------------------------------------------------
    //  debugger
    //
    generate
        if( enable_debug ) begin
            reg     [7:0]   debug_ram   [0:15];
            reg     [4:0]   ff_debug_ptr;
            reg     [7:0]   ff_debug_data;
            reg     [7:0]   ff_debug_read;
            reg             ff_debug_inc;

            //  debug RAM
            always @( posedge reset or posedge clk21m ) begin
                if( reset ) begin
                    ff_debug_ptr    <= 5'd0;
                end
                else if( clkena ) begin
                    if( ff_debug_inc && (ff_debug_ptr[4] == 1'b0) ) begin
                        ff_debug_ptr                    <= ff_debug_ptr + 5'd1;
                        debug_ram[ff_debug_ptr[3:0]]    <= ff_debug_data;
                    end
                end
            end

            always @( posedge clk21m ) begin
                if( clkena ) begin
                    if( PpiPortC[4] == 1'b0 ) begin
                        ff_debug_read                   <= debug_ram[PpiPortC[3:0]];
                    end
                end
            end

            always @( posedge reset or posedge clk21m ) begin
                if( reset ) begin
                    ff_debug_inc    <= 1'b0;
                end
                else if( clkena ) begin
                    if( w_timeout && (ff_ps2_sub_state == PS2_SUB_SND_REQUEST) ) begin
                        ff_debug_data   <= ff_ps2_snd_dat;
                        ff_debug_inc    <= 1'b1;
                    end
                    else if( w_ps2_rise_edge && (ff_ps2_sub_state == PS2_SUB_RCV_STOP) ) begin
                        ff_debug_data   <= ff_ps2_rcv_dat;
                        ff_debug_inc    <= 1'b1;
                    end
                    else begin
                        ff_debug_data   <= 8'd0;
                        ff_debug_inc    <= 1'b0;
                    end
                end
            end

            assign pKeyX = (PpiPortC[4] == 1'b0) ? ff_debug_read : ff_key_x;
        end
        else begin

            assign pKeyX = ff_key_x;
        end
    endgenerate

    // --------------------------------------------------------------------

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

    assign w_ps2_host_phase     = (                             ff_ps2_clk_latch == 1'b1 ) ? 1'b1 : 1'b0;
    assign w_ps2_rise_edge      = ( ff_ps2_clk_delay == 1'b0 && ff_ps2_clk_latch == 1'b1 ) ? 1'b1 : 1'b0;
    assign w_ps2_fall_edge      = ( ff_ps2_clk_delay == 1'b1 && ff_ps2_clk_latch == 1'b0 ) ? 1'b1 : 1'b0;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_ps2_state    <= PS2_ST_RESET;
            ff_ps2_send     <= 1'b0;
            ff_no_send      <= 1'b0;
        end
        else if( clkena ) begin
            if( w_timeout && ff_ps2_state != PS2_ST_RESET && ff_ps2_state != PS2_ST_SND_RESET && ff_ps2_state != PS2_ST_IDLE && ff_ps2_sub_state != PS2_SUB_SND_REQUEST ) begin
                //  for illegal keyboard
                ff_ps2_state    <= PS2_ST_IDLE;
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
                            //  hold
                        end
                    end
                PS2_ST_SND_RESET:
                    begin
                        ff_ps2_send     <= 1'b0;
                        if( ff_error ) begin
                            //  reset command error
                            ff_ps2_state    <= PS2_ST_SND_SETMON;
                            ff_ps2_send     <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= PS2_ST_RCV_ACK1;
                        end
                        else begin
                            //  hold
                        end
                    end
                PS2_ST_RCV_ACK1:
                    begin
                        if( ff_error ) begin
                            //  for illegal keyboard
                            ff_ps2_state    <= PS2_ST_SND_SETMON;
                            ff_ps2_send     <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hFA ) begin
                                ff_ps2_state    <= PS2_ST_RCV_BATCMP;
                            end
                            else begin
                                //  reset command error
                                ff_ps2_state    <= PS2_ST_SND_SETMON;
                                ff_ps2_send     <= 1'b1;
                            end
                        end
                    end
                PS2_ST_RCV_BATCMP:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hAA ) begin
                                ff_ps2_state    <= PS2_ST_SND_SETMON;
                                ff_ps2_send     <= 1'b1;
                            end
                            else begin
                                //  for illegal keyboard
                                ff_ps2_state    <= PS2_ST_SND_SETMON;
                                ff_ps2_send     <= 1'b1;
                            end
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                PS2_ST_SND_SETMON:
                    begin
                        ff_ps2_send     <= 1'b0;
                        if( ff_error ) begin
                            ff_ps2_state    <= PS2_ST_RECOVERY;
                            ff_no_send      <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= PS2_ST_RCV_ACK3;
                        end
                    end
                PS2_ST_RCV_ACK3:
                    begin
                        if( ff_error ) begin
                            ff_ps2_state    <= PS2_ST_RECOVERY;
                            ff_no_send      <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hFA ) begin
                                ff_ps2_state    <= PS2_ST_SND_OPT;
                                ff_ps2_send     <= 1'b1;
                            end
                            else begin
                                //  for illegal keyboard
                                ff_ps2_state    <= PS2_ST_RECOVERY;
                                ff_no_send      <= 1'b1;
                            end
                        end
                    end
                PS2_ST_SND_OPT:
                    begin
                        ff_ps2_send     <= 1'b0;
                        if( ff_error ) begin
                            ff_ps2_state    <= PS2_ST_RECOVERY;
                            ff_no_send      <= 1'b1;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= PS2_ST_RCV_ACK4;
                        end
                    end
                PS2_ST_RCV_ACK4:
                    begin
                        if( ff_error ) begin
                            ff_ps2_state    <= PS2_ST_IDLE;
                        end
                        else if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            if( ff_ps2_rcv_dat == 8'hFA ) begin
                                ff_ps2_state    <= PS2_ST_IDLE;
                            end
                            else begin
                                //  for illegal keyboard
                                ff_ps2_state    <= PS2_ST_RECOVERY;
                                ff_no_send      <= 1'b1;
                            end
                        end
                    end
                PS2_ST_IDLE:
                    begin
                        if( w_ps2_host_phase && w_ps2_led_change && !ff_f0_detect && !ff_e0_detect && !ff_e1_detect ) begin
                            if( !ff_no_send ) begin
                                ff_ps2_state    <= PS2_ST_SND_SETMON;
                                ff_ps2_send     <= 1'b1;
                            end
                            else begin
                                //  hold
                            end
                        end
                        else if( w_ps2_fall_edge ) begin
                            ff_ps2_state    <= PS2_ST_RCV_SCAN;
                            ff_ps2_send     <= 1'b0;
                        end
                        else begin
                            ff_ps2_send     <= 1'b0;
                        end
                    end
                PS2_ST_RCV_SCAN:
                    begin
                        if( ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                            ff_ps2_state    <= PS2_ST_IDLE;
                        end
                    end
                PS2_ST_RECOVERY:
                    begin
                        if( w_timeout ) begin
                            ff_ps2_state    <= PS2_ST_IDLE;
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
    localparam      TIMER_143USEC = 19'd512;        //  0.2794usec * 512clock       = 143.053usec (PS/2 spec. minimum 100usec)
    localparam      TIMER_12MSEC = 19'd42949;       //  0.2794usec * 42949clock     = 12msec
    localparam      TIMER_20MSEC = 19'd71582;       //  0.2794usec * 71582clock     = 20msec
    localparam      TIMER_120MSEC = 19'd429492;     //  0.2794usec * 429492clock    = 120msec

    assign w_timeout    = (ff_timer == 19'h00000) ? 1'b1 : 1'b0;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_timer <= TIMER_120MSEC;
        end
        else if( clkena ) begin
            if( w_timeout && (ff_ps2_state == PS2_ST_RESET || ff_ps2_state == PS2_ST_SND_RESET) ) begin
                ff_timer <= TIMER_120MSEC;
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
                ff_timer <= TIMER_143USEC;
            end
            else if( w_ps2_fall_edge && (
                    ff_ps2_sub_state == PS2_SUB_RCV_START ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D0 || ff_ps2_sub_state == PS2_SUB_RCV_D1 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D2 || ff_ps2_sub_state == PS2_SUB_RCV_D3 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D4 || ff_ps2_sub_state == PS2_SUB_RCV_D5 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_D6 || ff_ps2_sub_state == PS2_SUB_RCV_D7 ||
                    ff_ps2_sub_state == PS2_SUB_RCV_PARITY ) ) begin
                ff_timer <= TIMER_143USEC;
            end
            else if( ff_ps2_state != PS2_ST_RESET && ff_ps2_sub_state == PS2_SUB_IDLE ) begin
                if( ff_error ) begin
                    ff_timer <= TIMER_20MSEC;
                end
                if( ff_ps2_send ) begin
                    ff_timer <= TIMER_143USEC;
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
            else if( (ff_ps2_sub_state == PS2_SUB_SND_REQUEST) || (ff_ps2_state == PS2_ST_SND_RESET && ff_ps2_sub_state == PS2_SUB_IDLE) || (ff_ps2_state == PS2_ST_RECOVERY) ) begin
                ff_ps2_clk <= 1'b0;
            end
            else begin
                ff_ps2_clk <= 1'bZ;
            end
        end
    end

    assign pPs2Clk  = ff_ps2_clk;

    // ------------------------------------------------------------------------
    //  Shift/Control Keys
    // ------------------------------------------------------------------------
    reg     ff_shift_key;
    reg     ff_control_key;
    reg     ff_numlk_key;
    reg     ff_pause_toggle_key;
    reg     ff_reso_toggle_key;
    reg     ff_scrlk_toggle_key;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_shift_key        <= 1'b0;
            ff_control_key      <= 1'b0;
            ff_numlk_key        <= ~numlk_initial;
            ff_pause_toggle_key <= 1'b0;
            ff_reso_toggle_key  <= 1'b0;
            ff_scrlk_toggle_key <= 1'b0;
        end
        else if( clkena ) begin
            if( (ff_ps2_state == PS2_ST_RCV_SCAN) && (ff_ps2_sub_state == PS2_SUB_WAIT) ) begin
                if( ff_e1_detect == 1'b0 && ff_e0_detect == 1'b0 && (ff_ps2_rcv_dat == 8'h12 || ff_ps2_rcv_dat == 8'h59) ) begin
                    //  Shift Left == 'h12, Shift Right == 'h59
                    ff_shift_key <= ~ff_f0_detect;
                end
                if( ff_e1_detect == 1'b0 && ff_e0_detect == 1'b0 && ff_ps2_rcv_dat == 8'h14 ) begin
                    //  CTRL Left == 'h14   (Memo: CTRL Right == 'hE0:'h14 is EXECUTE, not CTRL)
                    ff_control_key <= ~ff_f0_detect;
                end
                if( ff_e1_detect == 1'b0 && ff_e0_detect == 1'b0 && ff_f0_detect == 1'b1 && ff_ps2_rcv_dat == 8'h77 ) begin
                    //  NumLk == 'h77
                    ff_numlk_key <= ~ff_numlk_key;
                end
                if( ff_e1_detect == 1'b1 && ff_f0_detect == 1'b1 && ff_ps2_rcv_dat == 8'h77 ) begin
                    //  Pause/Break == 'hE1:'h14:'h77:'hE1:'hF0:'h14:'hD0:'h77
                    ff_pause_toggle_key <= ~ff_pause_toggle_key;
                end
                if( ff_e1_detect == 1'b0 && ff_e0_detect == 1'b1 && ff_f0_detect == 1'b0 && ff_ps2_rcv_dat == 8'h7C ) begin
                    //  PrintScreen == 'hE0:'12:'hE0:'h7C (pressed), 'hE0:'hF0:'h7C:'hE0:'hF0:'h12 (released)
                    ff_reso_toggle_key <= ~ff_reso_toggle_key;
                end
                if( ff_e1_detect == 1'b0 && ff_e0_detect == 1'b0 && ff_f0_detect == 1'b0 && ff_ps2_rcv_dat == 8'h7E ) begin
                    //  ScrLk == 'h7E
                    ff_scrlk_toggle_key <= ~ff_scrlk_toggle_key;
                end
            end
        end
    end

    assign Paus     = ff_pause_toggle_key;
    assign Reso     = ff_reso_toggle_key;
    assign Scro     = ff_scrlk_toggle_key;

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
                if( ff_ps2_state == PS2_ST_SND_RESET ) begin
                    ff_ps2_snd_dat <= 8'hFF;
                end
                else if( ff_ps2_state == PS2_ST_SND_SETMON ) begin
                    ff_ps2_snd_dat <= 8'hED;
                end
                else if( ff_ps2_state == PS2_ST_SND_OPT ) begin
                    if( numlk_is_kana == 1'b1 ) begin
                        ff_ps2_snd_dat <= { 5'd0, ~Caps, ~Kana, CmtScro };
                    end
                    else begin
                        ff_ps2_snd_dat <= { 5'd0, ~Caps, ~ff_numlk_key, ~Kana };
                    end
                end
                else begin
                    //  hold
                end
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

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_f0_detect <= 1'b0;
            ff_e0_detect <= 1'b0;
            ff_e1_detect <= 1'b0;
        end
        else if( clkena ) begin
            if( ff_ps2_state == PS2_ST_RCV_SCAN && ff_ps2_sub_state == PS2_SUB_WAIT ) begin
                if( ff_ps2_rcv_dat == 8'hF0 ) begin
                    ff_f0_detect <= 1'b1;
                end
                else if( ff_ps2_rcv_dat == 8'hE0 ) begin
                    ff_e0_detect <= 1'b1;
                end
                else if( ff_ps2_rcv_dat == 8'hE1 ) begin
                    ff_e1_detect <= 1'b1;
                end
                else begin
                    ff_f0_detect <= 1'b0;
                    ff_e0_detect <= 1'b0;
                    if( ff_e1_detect && ff_f0_detect && ff_ps2_rcv_dat == 8'h77 ) begin
                        ff_e1_detect <= 1'b0;
                    end
                end
            end
        end
    end

    // ------------------------------------------------------------------------
    //  LED State
    // ------------------------------------------------------------------------
    reg     ff_led_caps_lock;
    reg     ff_led_kana_lock;
    reg     ff_led_scroll_lock;
    reg     ff_led_num_lock;

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_led_caps_lock    <= Caps;
            ff_led_kana_lock    <= Kana;
            ff_led_scroll_lock  <= CmtScro;
            ff_led_num_lock     <= ~numlk_initial;
        end
        else if( clkena ) begin
            if( ff_ps2_state == PS2_ST_SND_SETMON && ff_ps2_send ) begin
                ff_led_caps_lock    <= Caps;
                ff_led_kana_lock    <= Kana;
                ff_led_scroll_lock  <= CmtScro;
                ff_led_num_lock     <= ff_numlk_key;
            end
        end
    end
    assign w_ps2_led_change = (ff_led_caps_lock ^ Caps) |
                              (ff_led_kana_lock ^ Kana) |
                              (ff_led_scroll_lock ^ CmtScro) |
                              (ff_led_num_lock ^ ff_numlk_key);

    // ------------------------------------------------------------------------
    //  MSX Key Matrix Updater
    // ------------------------------------------------------------------------
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_matupd_state         <= MATUPD_ST_RESET;
            ff_matupd_rows          <= 4'd0;
            ff_matupd_we            <= 1'b1;
            ff_matupd_keys          <= 8'hFF;
            ff_ps2_virtual_shift    <= 1'b0;
            ff_func_keys            <= 6'b000000;
            ff_matupd_ppi_c         <= 1'b0;
            ff_e0_detect_dl         <= 1'b0;
        end
        else begin
            if( ff_matupd_state == MATUPD_ST_RESET ) begin
                //  MATUPD_ST_RESET: Clear all keys to unpressed state.
                ff_matupd_rows  <= ff_matupd_rows + 4'd1;
                if( ff_matupd_rows == 4'd15 ) begin
                    ff_matupd_state <= MATUPD_ST_IDLE;
                end
            end
            else if( ff_matupd_state == MATUPD_ST_IDLE ) begin
                ff_matupd_we    <= 1'b0;
                if( clkena && (ff_ps2_state == PS2_ST_RCV_SCAN) && (ff_ps2_sub_state == PS2_SUB_WAIT) && !ff_e1_detect ) begin
                    ff_matupd_state <= MATUPD_ST_KEYMAP_READ1;
                    ff_key_unpress  <= ff_f0_detect;
                    ff_e0_detect_dl <= ff_e0_detect;
                    ff_keymap_index <= { ~Kmap, ~ff_shift_key & Kmap, ff_e0_detect, ff_ps2_rcv_dat };
                    ff_matupd_ppi_c <= 1'b0;
                end
                else begin
                    ff_matupd_rows  <= PpiPortC[3:0];
                    ff_matupd_ppi_c <= 1'b1;
                end
            end
            //  Keymap によって [SHIFT] の有無で対応する MSX側マトリクスアドレスが変わることがある。
            //  キーの解放順序によってその不整合が発生しないように、現在押された/放されたキーの [SHIFT]キーの逆転キーに対応する MSXマトリクス
            //  ビットを、一旦放された状態に変更する。
            else if( ff_matupd_state == MATUPD_ST_KEYMAP_READ1 ) begin
                ff_matupd_state <= MATUPD_ST_MATRIX_READ1_REQ;
            end
            else if( ff_matupd_state == MATUPD_ST_MATRIX_READ1_REQ ) begin
                if( w_keymap_dat == 8'hFF ) begin
                    ff_matupd_state <= MATUPD_ST_KEYMAP_READ2;
                end
                else begin
                    ff_matupd_state <= MATUPD_ST_MATRIX_READ1_RES;
                    ff_matupd_rows  <= w_keymap_dat[3:0];
                    ff_key_bits     <= w_keymap_dat[7:4];
                end
            end
            else if( ff_matupd_state == MATUPD_ST_MATRIX_READ1_RES ) begin
                ff_matupd_state <= MATUPD_ST_MATRIX_WRITE1;
            end
            else if( ff_matupd_state == MATUPD_ST_MATRIX_WRITE1 ) begin
                ff_matupd_state <= MATUPD_ST_KEYMAP_READ2;
                ff_matupd_we    <= 1'b1;
                ff_matupd_keys  <= w_matrix | w_mask;
                ff_keymap_index <= { ~Kmap, ff_shift_key & Kmap, ff_e0_detect_dl, ff_ps2_rcv_dat };
            end
            //  ここからは、現在押された/放されたキーに対応する MSXマトリクスのビットを適切な値で上書きする
            else if( ff_matupd_state == MATUPD_ST_KEYMAP_READ2 ) begin
                ff_matupd_we    <= 1'b0;
                ff_matupd_state <= MATUPD_ST_MATRIX_READ2_REQ;
            end
            else if( ff_matupd_state == MATUPD_ST_MATRIX_READ2_REQ ) begin
                if( w_keymap_dat == 8'hFF ) begin
                    ff_matupd_state <= MATUPD_ST_IDLE;
                end
                else begin
                    ff_matupd_state <= MATUPD_ST_MATRIX_READ2_RES;
                    ff_matupd_rows  <= w_keymap_dat[3:0];
                    ff_key_bits     <= w_keymap_dat[7:4];
                end
            end
            else if( ff_matupd_state == MATUPD_ST_MATRIX_READ2_RES ) begin
                ff_matupd_state <= MATUPD_ST_MATRIX_WRITE2;
            end
            else if( ff_matupd_state == MATUPD_ST_MATRIX_WRITE2 ) begin
                ff_matupd_state <= MATUPD_ST_IDLE;
                ff_matupd_we    <= 1'b1;
                if( ff_key_unpress ) begin
                    ff_matupd_keys          <= w_matrix | w_mask;
                    ff_ps2_virtual_shift    <= ff_shift_key;
                end
                else begin
                    ff_matupd_keys          <= w_matrix & ~w_mask;
                    if( ff_matupd_rows == 4'hF ) begin
                        ff_func_keys <= ff_func_keys ^ w_mask[5:0];
                    end
                    else begin
                        ff_ps2_virtual_shift    <= ff_key_bits[3];
                    end
                end
            end
        end
    end

    assign Fkeys = { ff_shift_key, ff_control_key, ff_func_keys };

    function [7:0] func_mask(
        input   [3:0]   bits
    );
        case( bits[2:0] )
        3'd0:       func_mask = 8'b00000001;
        3'd1:       func_mask = 8'b00000010;
        3'd2:       func_mask = 8'b00000100;
        3'd3:       func_mask = 8'b00001000;
        3'd4:       func_mask = 8'b00010000;
        3'd5:       func_mask = 8'b00100000;
        3'd6:       func_mask = 8'b01000000;
        3'd7:       func_mask = 8'b10000000;
        default:    func_mask = 8'b00000000;
        endcase
    endfunction
    assign w_mask = func_mask( ff_key_bits );

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_key_x <= 8'hFF;
        end
        else if( ff_matupd_state == MATUPD_ST_IDLE ) begin
            if( ff_matupd_ppi_c ) begin
                ff_key_x <= w_matrix;
            end
            else begin
                //  hold
            end
        end
        else begin
            //  hold
        end
    end

    ram u_matrix_ram (
    .adr    ( { 4'd0, ff_matupd_rows }  ),
    .clk    ( clk21m                    ),
    .we     ( ff_matupd_we              ),
    .dbo    ( ff_matupd_keys            ),
    .dbi    ( w_matrix_pre              )
    );

    assign w_matrix[7:1]    = w_matrix_pre[7:1];
    assign w_matrix[0]      = ((Kmap == 1'b1) && (ff_matupd_rows == 4'd6)) ? ~ff_ps2_virtual_shift :        // Other Keymap
                              w_matrix_pre[0];

    keymap u_keymap (
    .adr    ( ff_keymap_index   ),
    .clk    ( clk21m            ),
    .dbi    ( w_keymap_dat      )
    );
endmodule
