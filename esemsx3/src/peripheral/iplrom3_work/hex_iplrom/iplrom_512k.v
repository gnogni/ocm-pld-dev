//
// iplrom_512k.v
//   IPL-ROM for OCM-PLD
//   Initial Program Loader for Cyclone & EPCS (Altera)
//   Revision 3.00
//
// Copyright (c) 2021-2024 Takayuki Hara
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

// IPL-ROM PRELOADER v1.02 for EPCS16 or higher

module iplrom (
    input           clk,
    input   [15:0]  adr,
    output  [ 7:0]  dbi
);
    reg     [ 7:0]  ff_dbi;

    always @( posedge clk ) begin
        case( adr[ 8:0] )
        9'h000:     ff_dbi <= 8'hf3;
        9'h001:     ff_dbi <= 8'h3e;
        9'h002:     ff_dbi <= 8'hd4;
        9'h003:     ff_dbi <= 8'hd3;
        9'h004:     ff_dbi <= 8'h40;
        9'h005:     ff_dbi <= 8'h3e;
        9'h006:     ff_dbi <= 8'h40;
        9'h007:     ff_dbi <= 8'h32;
        9'h008:     ff_dbi <= 8'h00;
        9'h009:     ff_dbi <= 8'h60;
        9'h00a:     ff_dbi <= 8'h3a;
        9'h00b:     ff_dbi <= 8'h00;
        9'h00c:     ff_dbi <= 8'h58;
        9'h00d:     ff_dbi <= 8'h4f;
        9'h00e:     ff_dbi <= 8'h3e;
        9'h00f:     ff_dbi <= 8'h60;
        9'h010:     ff_dbi <= 8'h32;
        9'h011:     ff_dbi <= 8'h00;
        9'h012:     ff_dbi <= 8'h60;
        9'h013:     ff_dbi <= 8'h3c;
        9'h014:     ff_dbi <= 8'h32;
        9'h015:     ff_dbi <= 8'h00;
        9'h016:     ff_dbi <= 8'h58;
        9'h017:     ff_dbi <= 8'h06;
        9'h018:     ff_dbi <= 8'ha0;
        9'h019:     ff_dbi <= 8'h3a;
        9'h01a:     ff_dbi <= 8'h00;
        9'h01b:     ff_dbi <= 8'h50;
        9'h01c:     ff_dbi <= 8'h00;
        9'h01d:     ff_dbi <= 8'h10;
        9'h01e:     ff_dbi <= 8'hfa;
        9'h01f:     ff_dbi <= 8'h3a;
        9'h020:     ff_dbi <= 8'h00;
        9'h021:     ff_dbi <= 8'h40;
        9'h022:     ff_dbi <= 8'haf;
        9'h023:     ff_dbi <= 8'h32;
        9'h024:     ff_dbi <= 8'h00;
        9'h025:     ff_dbi <= 8'h58;
        9'h026:     ff_dbi <= 8'h3e;
        9'h027:     ff_dbi <= 8'hff;
        9'h028:     ff_dbi <= 8'h32;
        9'h029:     ff_dbi <= 8'h00;
        9'h02a:     ff_dbi <= 8'h78;
        9'h02b:     ff_dbi <= 8'h06;
        9'h02c:     ff_dbi <= 8'h10;
        9'h02d:     ff_dbi <= 8'hc5;
        9'h02e:     ff_dbi <= 8'h11;
        9'h02f:     ff_dbi <= 8'hfa;
        9'h030:     ff_dbi <= 8'h07;
        9'h031:     ff_dbi <= 8'h21;
        9'h032:     ff_dbi <= 8'h00;
        9'h033:     ff_dbi <= 8'hb4;
        9'h034:     ff_dbi <= 8'h06;
        9'h035:     ff_dbi <= 8'h06;
        9'h036:     ff_dbi <= 8'hcd;
        9'h037:     ff_dbi <= 8'h8d;
        9'h038:     ff_dbi <= 8'h00;
        9'h039:     ff_dbi <= 8'hc1;
        9'h03a:     ff_dbi <= 8'h38;
        9'h03b:     ff_dbi <= 8'h0b;
        9'h03c:     ff_dbi <= 8'h3a;
        9'h03d:     ff_dbi <= 8'h00;
        9'h03e:     ff_dbi <= 8'hb4;
        9'h03f:     ff_dbi <= 8'hfe;
        9'h040:     ff_dbi <= 8'hf3;
        9'h041:     ff_dbi <= 8'h20;
        9'h042:     ff_dbi <= 8'h04;
        9'h043:     ff_dbi <= 8'h79;
        9'h044:     ff_dbi <= 8'hc3;
        9'h045:     ff_dbi <= 8'h00;
        9'h046:     ff_dbi <= 8'hb4;
        9'h047:     ff_dbi <= 8'h10;
        9'h048:     ff_dbi <= 8'he4;
        9'h049:     ff_dbi <= 8'h21;
        9'h04a:     ff_dbi <= 8'hb3;
        9'h04b:     ff_dbi <= 8'h00;
        9'h04c:     ff_dbi <= 8'h01;
        9'h04d:     ff_dbi <= 8'h99;
        9'h04e:     ff_dbi <= 8'h12;
        9'h04f:     ff_dbi <= 8'hed;
        9'h050:     ff_dbi <= 8'hb3;
        9'h051:     ff_dbi <= 8'h01;
        9'h052:     ff_dbi <= 8'h9a;
        9'h053:     ff_dbi <= 8'h20;
        9'h054:     ff_dbi <= 8'hed;
        9'h055:     ff_dbi <= 8'hb3;
        9'h056:     ff_dbi <= 8'h0d;
        9'h057:     ff_dbi <= 8'haf;
        9'h058:     ff_dbi <= 8'h16;
        9'h059:     ff_dbi <= 8'h20;
        9'h05a:     ff_dbi <= 8'hd3;
        9'h05b:     ff_dbi <= 8'h98;
        9'h05c:     ff_dbi <= 8'h10;
        9'h05d:     ff_dbi <= 8'hfc;
        9'h05e:     ff_dbi <= 8'h15;
        9'h05f:     ff_dbi <= 8'h20;
        9'h060:     ff_dbi <= 8'hf9;
        9'h061:     ff_dbi <= 8'h06;
        9'h062:     ff_dbi <= 8'h20;
        9'h063:     ff_dbi <= 8'h3e;
        9'h064:     ff_dbi <= 8'hf1;
        9'h065:     ff_dbi <= 8'hd3;
        9'h066:     ff_dbi <= 8'h98;
        9'h067:     ff_dbi <= 8'h10;
        9'h068:     ff_dbi <= 8'hfc;
        9'h069:     ff_dbi <= 8'h11;
        9'h06a:     ff_dbi <= 8'h40;
        9'h06b:     ff_dbi <= 8'h81;
        9'h06c:     ff_dbi <= 8'hed;
        9'h06d:     ff_dbi <= 8'h59;
        9'h06e:     ff_dbi <= 8'hed;
        9'h06f:     ff_dbi <= 8'h51;
        9'h070:     ff_dbi <= 8'h16;
        9'h071:     ff_dbi <= 8'h08;
        9'h072:     ff_dbi <= 8'hed;
        9'h073:     ff_dbi <= 8'h51;
        9'h074:     ff_dbi <= 8'hed;
        9'h075:     ff_dbi <= 8'h59;
        9'h076:     ff_dbi <= 8'h0d;
        9'h077:     ff_dbi <= 8'h06;
        9'h078:     ff_dbi <= 8'h20;
        9'h079:     ff_dbi <= 8'hed;
        9'h07a:     ff_dbi <= 8'hb3;
        9'h07b:     ff_dbi <= 8'h3e;
        9'h07c:     ff_dbi <= 8'h01;
        9'h07d:     ff_dbi <= 8'hcd;
        9'h07e:     ff_dbi <= 8'h05;
        9'h07f:     ff_dbi <= 8'h01;
        9'h080:     ff_dbi <= 8'h3e;
        9'h081:     ff_dbi <= 8'h35;
        9'h082:     ff_dbi <= 8'hd3;
        9'h083:     ff_dbi <= 8'h41;
        9'h084:     ff_dbi <= 8'h3e;
        9'h085:     ff_dbi <= 8'h1f;
        9'h086:     ff_dbi <= 8'hd3;
        9'h087:     ff_dbi <= 8'h41;
        9'h088:     ff_dbi <= 8'h3e;
        9'h089:     ff_dbi <= 8'h23;
        9'h08a:     ff_dbi <= 8'hd3;
        9'h08b:     ff_dbi <= 8'h41;
        9'h08c:     ff_dbi <= 8'h76;
        9'h08d:     ff_dbi <= 8'hd5;
        9'h08e:     ff_dbi <= 8'heb;
        9'h08f:     ff_dbi <= 8'h29;
        9'h090:     ff_dbi <= 8'heb;
        9'h091:     ff_dbi <= 8'haf;
        9'h092:     ff_dbi <= 8'h48;
        9'h093:     ff_dbi <= 8'h47;
        9'h094:     ff_dbi <= 8'hc5;
        9'h095:     ff_dbi <= 8'he5;
        9'h096:     ff_dbi <= 8'h21;
        9'h097:     ff_dbi <= 8'h00;
        9'h098:     ff_dbi <= 8'h40;
        9'h099:     ff_dbi <= 8'h36;
        9'h09a:     ff_dbi <= 8'h03;
        9'h09b:     ff_dbi <= 8'h72;
        9'h09c:     ff_dbi <= 8'h73;
        9'h09d:     ff_dbi <= 8'h77;
        9'h09e:     ff_dbi <= 8'hbe;
        9'h09f:     ff_dbi <= 8'hd1;
        9'h0a0:     ff_dbi <= 8'h79;
        9'h0a1:     ff_dbi <= 8'h48;
        9'h0a2:     ff_dbi <= 8'he5;
        9'h0a3:     ff_dbi <= 8'h06;
        9'h0a4:     ff_dbi <= 8'h02;
        9'h0a5:     ff_dbi <= 8'hed;
        9'h0a6:     ff_dbi <= 8'hb0;
        9'h0a7:     ff_dbi <= 8'he1;
        9'h0a8:     ff_dbi <= 8'h3d;
        9'h0a9:     ff_dbi <= 8'h20;
        9'h0aa:     ff_dbi <= 8'hf7;
        9'h0ab:     ff_dbi <= 8'h3a;
        9'h0ac:     ff_dbi <= 8'h00;
        9'h0ad:     ff_dbi <= 8'h50;
        9'h0ae:     ff_dbi <= 8'he1;
        9'h0af:     ff_dbi <= 8'hd1;
        9'h0b0:     ff_dbi <= 8'h19;
        9'h0b1:     ff_dbi <= 8'heb;
        9'h0b2:     ff_dbi <= 8'hc9;
        9'h0b3:     ff_dbi <= 8'h06;
        9'h0b4:     ff_dbi <= 8'h82;
        9'h0b5:     ff_dbi <= 8'h80;
        9'h0b6:     ff_dbi <= 8'h83;
        9'h0b7:     ff_dbi <= 8'h00;
        9'h0b8:     ff_dbi <= 8'h84;
        9'h0b9:     ff_dbi <= 8'h36;
        9'h0ba:     ff_dbi <= 8'h85;
        9'h0bb:     ff_dbi <= 8'h00;
        9'h0bc:     ff_dbi <= 8'h86;
        9'h0bd:     ff_dbi <= 8'hf1;
        9'h0be:     ff_dbi <= 8'h87;
        9'h0bf:     ff_dbi <= 8'h00;
        9'h0c0:     ff_dbi <= 8'h8a;
        9'h0c1:     ff_dbi <= 8'h00;
        9'h0c2:     ff_dbi <= 8'h8b;
        9'h0c3:     ff_dbi <= 8'h00;
        9'h0c4:     ff_dbi <= 8'h40;
        9'h0c5:     ff_dbi <= 8'h00;
        9'h0c6:     ff_dbi <= 8'h00;
        9'h0c7:     ff_dbi <= 8'h00;
        9'h0c8:     ff_dbi <= 8'h00;
        9'h0c9:     ff_dbi <= 8'h22;
        9'h0ca:     ff_dbi <= 8'h06;
        9'h0cb:     ff_dbi <= 8'h34;
        9'h0cc:     ff_dbi <= 8'h07;
        9'h0cd:     ff_dbi <= 8'h37;
        9'h0ce:     ff_dbi <= 8'h03;
        9'h0cf:     ff_dbi <= 8'h47;
        9'h0d0:     ff_dbi <= 8'h04;
        9'h0d1:     ff_dbi <= 8'h53;
        9'h0d2:     ff_dbi <= 8'h03;
        9'h0d3:     ff_dbi <= 8'h47;
        9'h0d4:     ff_dbi <= 8'h06;
        9'h0d5:     ff_dbi <= 8'h63;
        9'h0d6:     ff_dbi <= 8'h03;
        9'h0d7:     ff_dbi <= 8'h64;
        9'h0d8:     ff_dbi <= 8'h04;
        9'h0d9:     ff_dbi <= 8'h63;
        9'h0da:     ff_dbi <= 8'h06;
        9'h0db:     ff_dbi <= 8'h65;
        9'h0dc:     ff_dbi <= 8'h06;
        9'h0dd:     ff_dbi <= 8'h11;
        9'h0de:     ff_dbi <= 8'h05;
        9'h0df:     ff_dbi <= 8'h56;
        9'h0e0:     ff_dbi <= 8'h03;
        9'h0e1:     ff_dbi <= 8'h66;
        9'h0e2:     ff_dbi <= 8'h06;
        9'h0e3:     ff_dbi <= 8'h77;
        9'h0e4:     ff_dbi <= 8'h07;
        9'h0e5:     ff_dbi <= 8'h49;
        9'h0e6:     ff_dbi <= 8'h49;
        9'h0e7:     ff_dbi <= 8'hff;
        9'h0e8:     ff_dbi <= 8'hff;
        9'h0e9:     ff_dbi <= 8'hff;
        9'h0ea:     ff_dbi <= 8'hff;
        9'h0eb:     ff_dbi <= 8'hff;
        9'h0ec:     ff_dbi <= 8'hbf;
        9'h0ed:     ff_dbi <= 8'h20;
        9'h0ee:     ff_dbi <= 8'h20;
        9'h0ef:     ff_dbi <= 8'hf0;
        9'h0f0:     ff_dbi <= 8'hf0;
        9'h0f1:     ff_dbi <= 8'hf0;
        9'h0f2:     ff_dbi <= 8'hf0;
        9'h0f3:     ff_dbi <= 8'hf0;
        9'h0f4:     ff_dbi <= 8'hf0;
        9'h0f5:     ff_dbi <= 8'hff;
        9'h0f6:     ff_dbi <= 8'h49;
        9'h0f7:     ff_dbi <= 8'h49;
        9'h0f8:     ff_dbi <= 8'h00;
        9'h0f9:     ff_dbi <= 8'h02;
        9'h0fa:     ff_dbi <= 8'h07;
        9'h0fb:     ff_dbi <= 8'h0f;
        9'h0fc:     ff_dbi <= 8'h1f;
        9'h0fd:     ff_dbi <= 8'hf0;
        9'h0fe:     ff_dbi <= 8'h20;
        9'h0ff:     ff_dbi <= 8'h20;
        9'h100:     ff_dbi <= 8'h00;
        9'h101:     ff_dbi <= 8'h00;
        9'h102:     ff_dbi <= 8'h00;
        9'h103:     ff_dbi <= 8'h80;
        9'h104:     ff_dbi <= 8'hc0;
        9'h105:     ff_dbi <= 8'h21;
        9'h106:     ff_dbi <= 8'h01;
        9'h107:     ff_dbi <= 8'h58;
        9'h108:     ff_dbi <= 8'hcd;
        9'h109:     ff_dbi <= 8'h0d;
        9'h10a:     ff_dbi <= 8'h01;
        9'h10b:     ff_dbi <= 8'h2e;
        9'h10c:     ff_dbi <= 8'h21;
        9'h10d:     ff_dbi <= 8'h0e;
        9'h10e:     ff_dbi <= 8'h99;
        9'h10f:     ff_dbi <= 8'hed;
        9'h110:     ff_dbi <= 8'h69;
        9'h111:     ff_dbi <= 8'hed;
        9'h112:     ff_dbi <= 8'h61;
        9'h113:     ff_dbi <= 8'hd3;
        9'h114:     ff_dbi <= 8'h98;
        9'h115:     ff_dbi <= 8'h3c;
        9'h116:     ff_dbi <= 8'hd3;
        9'h117:     ff_dbi <= 8'h98;
        9'h118:     ff_dbi <= 8'h3c;
        9'h119:     ff_dbi <= 8'hc9;
// Tip: a default value of 0xFF is better processed by the compiler.
        default:    ff_dbi <= 8'hff;
        endcase
    end

    assign dbi = ff_dbi;
endmodule
