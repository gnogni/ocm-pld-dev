//
// megasd.v
//   SD/MMC card interface
//   Revision 2.00
//
// Copyright (c) 2022 t.hara
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
// ----------------------------------------------------------------------------
// History:
//
// ----------------------------------------------------------------------------

module megasd (
    input               clk21m,
    input               reset,
    input               req,
    input               wrt,
    input       [15:0]  adr,
    input       [7:0]   dbo,

    output              ramreq,
    output              ramwrt,
    output      [19:0]  ramadr,

    output      [7:0]   mmcdbi,
    output              mmcena,
    output              mmcact,

    output              mmc_ck,
    output              mmc_cs,
    output reg          mmc_di,
    input               mmc_do,

    output              epc_ck,
    output              epc_cs,
    output              epc_oe,
    output reg          epc_di,
    input               epc_do,

    output  [7:0]       debug
);
    reg     [ 7:0]  ff_bank0;
    reg     [ 6:0]  ff_bank1;
    reg     [ 7:0]  ff_bank2;
    reg     [ 7:0]  ff_bank3;

    reg     [ 4:0]  ff_divider;
    wire            w_336k;
    wire            w_clk_enable;

    reg     [4:0]   ff_data_seq;
    reg             ff_data_active;

    wire            w_is_mmc_bank;

    reg             ff_low_speed_mode;
    reg             ff_power_on_reset = 1'b1;
    reg             ff_data_en;
    reg             ff_read_busy;
    wire            w_epc_mode;

    reg     [7:0]   ff_recv_data;
    reg     [7:0]   ff_send_data;
    reg     [7:0]   ff_mmcdbi;

    reg             ff_mmc_cs;
    reg             ff_epc_cs;
    reg             ff_mmc_ck;
    reg             ff_epc_ck;

    // ------------------------------------------------------------------------
    // ESE-RAM bank registers
    // ------------------------------------------------------------------------
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_bank0    <= 8'd0;
            ff_bank1    <= 7'd0;
            ff_bank2    <= 8'd0;
            ff_bank3    <= 8'd0;
        end
        else if( req && wrt && (adr[15:13] == 3'b011) ) begin
            // Memory mapped I/O 6000h-7FFFh
            case( adr[12:11] )
            2'b00:      ff_bank0 <= dbo;
            2'b01:      ff_bank1 <= dbo[6:0];
            2'b10:      ff_bank2 <= dbo;
            default:    ff_bank3 <= dbo;
            endcase
        end
    end

    assign ramreq   = ( !wrt ) ? req :
                      ( ff_bank0[7] && adr[14:13] == 2'b10 ) ? req :
                      ( ff_bank2[7] && adr[14:13] == 2'b00 ) ? req :
                      ( ff_bank3[7] && adr[14:13] == 2'b01 ) ? req : 1'b0;
    assign ramwrt   = wrt;
    assign ramadr   = ( adr[14:13] == 2'b10 ) ? { ff_bank0[6:0], adr[12:0] } :
                      ( adr[14:13] == 2'b11 ) ? { ff_bank1[6:0], adr[12:0] } :
                      ( adr[14:13] == 2'b00 ) ? { ff_bank2[6:0], adr[12:0] } : { ff_bank3[6:0], adr[12:0] };

    assign w_is_mmc_bank    = (ff_bank0[7:6] == 2'b01) ? 1'b1 : 1'b0;
    assign w_epc_mode       = (ff_bank0[7:4] == 4'd6 ) ? 1'b1 : 1'b0;

    //--------------------------------------------------------------
    // SD/MMC card access
    //--------------------------------------------------------------

    //  Clock divider
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_divider  <= 5'd0;
        end
        else if( req ) begin
            ff_divider  <= 5'd0;
        end
        else begin
            ff_divider  <= ff_divider + 5'd1;
        end
    end

    assign w_336k       = (ff_divider == 5'd31) ? 1'b1 : 1'b0;
    assign w_clk_enable = (ff_low_speed_mode) ? w_336k : 1'b1;

    always @( posedge reset or posedge clk21m ) begin
        if( reset == 1'b1 ) begin
            ff_mmc_ck   <= 1'b0;
            ff_epc_ck   <= 1'b0;
        end
        else if( w_clk_enable ) begin
            if( (ff_data_seq[4:1] != 4'd10) && (ff_data_seq[4:2] != 3'd0) ) begin
                if( w_epc_mode == 1'b0 ) begin
                    ff_mmc_ck <= ff_data_seq[0];
                    ff_epc_ck <= 1'b0;
                end
                else begin
                    ff_mmc_ck <= 1'b0;
                    ff_epc_ck <= ff_data_seq[0];
                end
            end
            else begin
                ff_mmc_ck <= 1'b0;
                ff_epc_ck <= 1'b0;
            end
        end
        else begin
            //  hold
        end
    end

    assign mmc_ck       = ff_mmc_ck;
    assign epc_ck       = ff_epc_ck;

    //  data sequence state
    always @( posedge reset or posedge clk21m ) begin
        if( reset == 1'b1 ) begin
            ff_data_seq <= 5'd0;
        end
        else begin
            // Memory mapped I/O port access on 4000-57FFh ... SD/MMC data register
            if( req == 1'b1 && adr[15:13] == 3'b010 && adr[12:11] != 2'b11 &&
                    w_is_mmc_bank == 1'b1 && ff_data_seq == 5'd0 && ff_data_en ) begin
                ff_data_seq <= 5'd21;
            end
            else if( w_clk_enable && (ff_data_seq != 5'd0) ) begin
                ff_data_seq <= ff_data_seq - 5'd1;
            end
        end
    end

    //  Mode register (5800h-5FFFh)
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_low_speed_mode   <= 1'b0;
            ff_data_en          <= 1'b1;
        end
        else if( req && wrt && (adr[15:12] == 4'd5) && (adr[11] == 1'b1) && w_is_mmc_bank ) begin
            ff_low_speed_mode   <= dbo[7];
            ff_data_en          <= ~dbo[0];
            ff_power_on_reset   <= 1'b0;
        end
        else begin
            //  hold
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_read_busy    <= 1'b0;
        end
        else if( req && !wrt && (adr[15:12] == 4'd5) && (adr[11:10] == 2'b10) && w_is_mmc_bank ) begin
            //  Address 0x5800-0x5BFF
            ff_read_busy    <= 1'b1;
        end
        else if( req && !wrt && w_is_mmc_bank ) begin
            //  Address 0x4000-0x57FF, 0x5C00-0x5FFF
            ff_read_busy    <= 1'b0;
        end
        else begin
            //  hold
        end
    end

    //  Shift register (4000h-57FFh)
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_data_active  <= 1'b0;
        end
        else if( req && ((adr[15:12] == 4'd4) || (adr[15:11] == { 4'd5, 1'b0 })) && w_is_mmc_bank ) begin
            ff_data_active  <= ff_data_en;
        end
        else if( w_clk_enable && (ff_data_seq == 5'd1) ) begin
            ff_data_active  <= 1'b0;
        end
        else begin
            //  hold
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset == 1'b1 ) begin
            ff_recv_data <= 8'hFF;
        end
        else if( w_clk_enable && (ff_data_seq[0] == 1'b0) ) begin
            ff_recv_data[7:1]   <= ff_recv_data[6:0];

            if( w_epc_mode == 1'b0 ) begin
                ff_recv_data[0] <= mmc_do;
            end
            else begin
                ff_recv_data[0] <= epc_do;
            end
        end
        else begin
            //  hold
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset == 1'b1 ) begin
            ff_mmcdbi <= 8'hFF;
        end
        else if( ff_data_seq == 5'd2 ) begin
            ff_mmcdbi <= ff_recv_data;
        end
        else begin
            //  hold
        end
    end

    assign mmcdbi   = (ff_read_busy) ? { ff_data_active, 6'd0, ff_power_on_reset } : ff_mmcdbi;
    assign debug    = ff_mmcdbi;

    always @( posedge reset or posedge clk21m ) begin
        if( reset == 1'b1 ) begin
            ff_send_data <= 8'hFF;
        end
        else if( req == 1'b1 && adr[15:13] == 3'b010 && adr[12:11] != 2'b11 &&
                    w_is_mmc_bank == 1'b1 && ff_data_seq == 5'd0 && ff_data_en ) begin
            // Memory mapped I/O port access on 4000-57FFh ... SD/MMC data register
            if( wrt == 1'b1 ) begin
                ff_send_data <= dbo;
            end
            else begin
                ff_send_data <= 8'hFF;
            end
        end
        else if( w_clk_enable && (ff_data_seq[0] == 1'b0) ) begin
            ff_send_data[7:1]   <= ff_send_data[6:0];
            ff_send_data[0] <= 1'b1;
        end
    end

    always @( posedge reset or posedge clk21m ) begin
        if( reset == 1'b1 ) begin
            mmc_di <= 1'bZ;
            epc_di <= 1'b1;
        end
        else if( ff_data_seq == 5'd0 ) begin
            //  hold
        end
        else if( w_clk_enable && (ff_data_seq[0] == 1'b0) ) begin
            if( ff_data_seq[4:2] == 3'd0 ) begin
                mmc_di      <= 1'bZ;
                epc_di      <= 1'b1;
            end
            else begin
                mmc_di      <= ff_send_data[7];
                epc_di      <= ff_send_data[7];
            end
        end
        else begin
            //  hold
        end
    end

    assign epc_oe           = reset;                        // epc_oe = 0:enable, 1:disable
    assign mmcact           = ff_data_active;
    assign mmcena           = w_is_mmc_bank;

    //  Chip Select
    always @( posedge reset or posedge clk21m ) begin
        if( reset ) begin
            ff_mmc_cs       <= 1'b1;
            ff_epc_cs       <= 1'b1;
        end
        else if( req && (adr[15:13] == 3'b010) && (adr[12:11] != 2'b11) && w_is_mmc_bank && ff_data_seq == 5'd0 ) begin
            //  Memory mapped I/O 4000-57FFh
            ff_mmc_cs       <=  w_epc_mode | adr[12];
            ff_epc_cs       <= !w_epc_mode | adr[12];
        end
        else begin
            //  hold
        end
    end

    assign mmc_cs           = ff_mmc_cs;
    assign epc_cs           = ff_epc_cs;
endmodule
