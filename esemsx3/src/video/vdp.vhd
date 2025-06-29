--
--  vdp.vhd
--   Top VHDL Source of ESE-VDP.
--
--  Copyright (C) 2000-2006 Kunihiko Ohnaka
--  All rights reserved.
--                                     http://www.ohnaka.jp/ese-vdp/
--
--  本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
--  満たす場合に限り、再頒布および使用が許可されます。
--
--  1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
--    免責条項をそのままの形で保持すること。
--  2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
--    著作権表示、本条件一覧、および下記免責条項を含めること。
--  3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
--    に使用しないこと。
--
--  本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
--  特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
--  的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
--  発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
--  その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
--  されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
--  ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
--  れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
--  たは結果損害について、一切責任を負わないものとします。
--
--  Note that above Japanese version license is the formal document.
--  The following translation is only for reference.
--
--  Redistribution and use of this software or any derivative works,
--  are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  3. Redistributions may not be sold, nor may they be used in a
--     commercial product or activity without specific prior written
--     permission.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
-- Contributors
--
--   Kazuhiro Tsujikawa
--     - Bug fixes
--   Alex Wulms
--     - Bug fixes
--     - Expansion and improvement of the VDP-Command engine
--     - Improvement of the TEXT2 mode.
--
-------------------------------------------------------------------------------
-- Memo
--   Japanese comment lines are starts with "JP:".
--   JP: 日本語のコメント行は JP:を頭に付ける事にする
--
-------------------------------------------------------------------------------
-- Revision History
--
-- 15th,May,2025 modified by KdL
--  - Optimization of SSG logic for reduction of LEs
--
-- 01st,May,2025 modified by KdL
--  - New VDP wait controller optimized for using Block RAM
--  - Fixed vertical blanking to prevent title screen freeze in Space Mambow
--
-- 21st,Apr,2025 modified by KdL
--  - Added VGA_INT_FIELD to select single or duplicate VGA interlacing
--
-- 12th,Jan,2025 modified by KdL
--  - Calibrated the delay of the split-screen cutoff for Screen2/4
--  - Temporary workaround for VDP S#0 bit6 functionality using SPMAXSPR
--
-- 25th,Dec,2024 modified by KdL
--  - Improved the sprite disabling by adjusting the timing of REG_R8_SP_OFF
--
-- 18th,Dec,2024 modified by KdL
--  - Exported interlace mode state to disable VGA scanlines
--
-- 29th,Jul,2023 modified by lfantoniosi
--  - Fixed overscan and optimized vertical blanking
--
-- 11th,Jun,2023 modified by lfantoniosi
--  - Temporary fix for sprites crossing the split-screen boundary
--
-- 07th,Jun,2023 modified by lfantoniosi
--  - Fixed sprite multiplexing issues for games like Zanac A.I. (VDP S#0 bit6)
--  - Added SPMAXSPR to select MSX1 sprite limit between 4 and 8
--
-- 24th,Sep,2022 modified by t.hara
--  - Fixed VDP R#8 initialization and rounding in YJK mode
--
-- 23rd,Oct,2021 modified by t.hara
--  - Improved VDP R#23 and added support for TEXTQ and MULTIQ modes
--  - Fixed damaged graphics in Fighter's Ragnarök (VDP R#17)
--
-- 09th,Jan,2020 modified by Ducasp
--  - Fixed the lack of page flipping capability (VDP R#13)
--
-- 20th,May,2019 modified by KdL
--  - Improved VDP wait controller
--
-- 3rd,June,2018 modified by KdL
--  - Improved the VGA up-scan converter
--
-- 15th,March,2017 modified by KdL
--  - Improved ENAHSYNC, thanks to Grauw
--
-- 27th,July,2014 modified by KdL
--  - Fixed H-SYNC interrupt reset control
--
-- 23rd,January,2013 modified by KdL
--  - Fixed V-SYNC and H-SYNC interrupt
--  - Added an extra signal to force NTSC/PAL modes
--
-- 29th,October,2006 modified by Kunihiko Ohnaka
--  - Added the license text
--  - Added the document part below
--
-- 3rd,Sep,2006 modified by Kunihiko Ohnaka
--  - Fixed several UNKNOWN REALITY problems
--  - Horizontal sprite problem
--  - Overscan problem
--  - [NOP] zoom demo problem
--  - 'Star Wars Scroll' demo problem
--
-- 20th,Aug,2006 modified by Kunihiko Ohnaka
--  - Separate SPRITE module
--  - Fixed the palette rewriting timing problem
--  - Added the interlace double resolution function (two page mode)
--
-- 15th,Aug,2006 modified by Kunihiko Ohnaka
--  - Separate VDP_NTSC sync generator module
--  - Separate screen mode modules
--  - Fixed the sprite posision problem on GRAPHIC6
--
-- 15th,Jan,2006 modified by Alex Wulms
-- text 2 mode  : debug blink function
-- high-res modi: debug 'screen off'
-- text 1&2 mode: debug VdpR23 scroll and color "0000" handling
-- all modi     : precalculate adjustx, adjusty once per line

-- 1st,Jan,2006 modified by Alex Wulms
-- Added the blink support to text 2 mode
--
-- 16th,Aug,2005 modified by Kazuhiro Tsujikawa
-- JP: TMS9918モードでVRAMインクリメントを下位14ビットに限定
--
-- 8th,May,2005 modified by Kunihiko Ohnaka
-- JP: VGAコンポーネントにInerlaceMode信号を伝えるようにした
--
-- 26th,April,2005 modified by Kazuhiro Tsujikawa
-- JP: VRAMとのデータバス(pRamDbi/pRamDbo)を単方向バス化(SDRAM対応)
--
-- 8th,November,2004 modified by Kazuhiro Tsujikawa
-- JP: Vsync/Hsync割り込み修正ミス訂正
--
-- 3rd,November,2004 modified by Kazuhiro Tsujikawa
-- JP: SCREEN6画面周辺色修正→MSX2タイトルロゴ対応
--
-- 19th,September,2004 modified by Kazuhiro Tsujikawa
-- JP: パターンネームテーブルのマスクを実装→ANMAデモ対応
-- JP: MultiColorMode(SCREEN3)実装→マジラビデモ対応
--
-- 12th,September,2004 modified by Kazuhiro Tsujikawa
-- JP: VdpR0DispNum等をライン単位で反映→スペースマンボウでのチラツキ対策
--
-- 11th,September,2004 modified by Kazuhiro Tsujikawa
-- JP: 水平帰線割り込み修正→MGSEL(テンポ早送り)対策
--
-- 22nd,August,2004 modified by Kazuhiro Tsujikawa
-- JP: パレットのRead/Write衝突を修正→ガゼルでのチラツキ対策
--
-- 21st,August,2004 modified by Kazuhiro Tsujikawa
-- JP: R1/IE0(垂直帰線割り込み許可)の動作を修正→GALAGA対策
--
-- 2nd,August,2004 modified by Kazuhiro Tsujikawa
-- JP: Screen7/8でのスプライト読み込みアドレスを修正→Snatcher対策
--
-- 31st,July,2004 modified by Kazuhiro Tsujikawa
-- JP: Screen7/8でのVRAM読み込みアドレスを修正→Snatcher対策
--
-- 24th,July,2004 modified by Kazuhiro Tsujikawa
-- JP: スプライト32枚同時表示時の乱れを修正(248=256-8->preDotCounter_x_end)
--
-- 18th,July,2004 modified by Kazuhiro Tsujikawa
-- JP: Screen6のレンダリング部を作成
--
-- 17th,July,2004 modified by Kazuhiro Tsujikawa
-- JP: Screen7のレンダリング部を作成
--
-- 29th,June,2004 modified by Kazuhiro Tsujikawa
-- JP: Screen8のレンダリング部を修正
--
-- 26th,June,2004 modified by Kazuhiro Tsujikawa
-- JP: WebPackでコンパイルするとHMMC/LMMC/LMCMが動作しない不具合を修正
-- JP: onehot sequencer(VdpCmdState) must be initialized by asyncronus RESET
--
-- 22nd,June,2004 modified by Kazuhiro Tsujikawa
-- JP: R1/IE0(垂直帰線割り込み許可)の動作を修正
-- JP: Ys2でバノアの家に入れる様になった
--
-- 13th,June,2004 modified by Kazuhiro Tsujikawa
-- JP: 拡大スプライトが右に1ドットずれる不具合を修正
-- JP: SCREEN5でスプライト右端32ドットが表示されない不具合を修正
-- JP: SCREEN5で211ライン(最下)のスプライトが表示されない不具合を修正
-- JP: 画面消去フラグ(VdpR1DispOn)を1ライン単位で反映する様に修正
--
-- 21st,March,2004 modified by Alex Wulms
-- Several enhancements to command engine:
--   Added PSET,LINE,SRCH,POINT
--   Added the screen 6,7,8 support
--   Improved the existing commands
--
-- 15th,January,2004 modified by Kunihiko Ohnaka
-- JP: VDPコマンドの実装を開始
-- JP: HMMC,HMMM,YMMM,HMMV,LMMC,LMMM,LMMVを実装.まだ不具合あり.
--
-- 12th,January,2004 modified by Kunihiko Ohnaka
-- JP: コメントの修正
--
-- 30th,December,2003 modified by Kazuhiro Tsujikawa
-- JP: 起動時の画面モードをVDP_NTSCと VGAのどちらにするかを，外部入力で切替
-- JP: DHClk/DLClkを一時的に復活させた
--
-- 16th,December,2003 modified by Kunihiko Ohnaka
-- JP: 起動時の画面モードをVDP_NTSCと VGAのどちらにするかを，vdp_package.vhd
-- JP: 内で定義された定数で切替えるようにした．
--
-- 10th,December,2003 modified by Kunihiko Ohnaka
-- JP: TEXT MODE 2 (SCREEN0 WIDTH80)をサポート．
-- JP: 初の横方向倍解像度モードである．一応将来対応できるように作って
-- JP: きたつもりだったが，少し収まりが悪い部分があり，あまりきれいな
-- JP: 対応になっていない部分もあります．
--
-- 13th,October,2003 modified by Kunihiko Ohnaka
-- JP: ESE-MSX基板では 2S300Eを複数用いる事ができるようにり，VDP単体で
-- JP: 2S300Eや SRAMを占有する事が可能となった．
-- JP: これに伴い以下のような変更を行う．
-- JP: ・VGA出力対応(アップスキャンコンバート)
-- JP: ・SCREEN7,8のタイミングを実機と同じに
--
-- 15th,June,2003 modified by Kunihiko Ohnaka
-- JP:水平帰線期間割り込みを実装してスペースマンボウを遊べるようにした．
-- JP:GraphicMode3(Screen4)でYライン数が 212ラインにならなかったのを
-- JP:修正したりした．
-- JP:ただし，スペースマンボウで set adjust機能が動いていないような
-- JP:感じで，表示がガクガクしてしまう．横方向の同時表示スプライト数も
-- JP:足りていないように見える．原因不明．
--
-- 15th,June,2003 modified by Kunihiko Ohnaka
-- JP:長いブランクが空いてしまったが，Spartan-II E + IO基板でスプライトが
-- JP:表示されるようになった．原因はおそらくコンパイラのバグで，ISE 5.2に
-- JP:バージョンアップしたら表示されるようになった．
-- JP:ついでに，スプライトモード2で横 8枚並ぶようにした(つもり)．
-- JP:その他細かな修正が入っています．
--
-- 15th,July,2002 modified by Kazuhiro Tsujikawa
-- no comment;
--
-- 5th,September,2019 modified by Oduvaldo Pavan Junior
-- Fixed the lack of page flipping (R13) capability
--
-- Added the undocumented feature where R1 bit #2 change the blink counter
-- clock source from VSYNC to HSYNC
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: ESE-VDPのトップエンティティです。CPUとのインターフェース、
-- JP: 画面描画タイミングの生成、VDPレジスタの実装などが含まれて
-- JP: います。
--

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
    USE IEEE.STD_LOGIC_ARITH.ALL;
    USE WORK.VDP_PACKAGE.ALL;

ENTITY VDP IS
    PORT(
        -- VDP CLOCK ... 21.477MHZ
        CLK21M              : IN    STD_LOGIC;
        RESET               : IN    STD_LOGIC;
        REQ                 : IN    STD_LOGIC;
        ACK                 : OUT   STD_LOGIC;
        WRT                 : IN    STD_LOGIC;
        ADR                 : IN    STD_LOGIC_VECTOR( 15 DOWNTO 0 );
        DBI                 : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        DBO                 : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );

        INT_N               : OUT   STD_LOGIC;

        PRAMOE_N            : OUT   STD_LOGIC;
        PRAMWE_N            : OUT   STD_LOGIC;
        PRAMADR             : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );
        PRAMDBI             : IN    STD_LOGIC_VECTOR( 15 DOWNTO 0 );
        PRAMDBO             : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );

        VDPSPEEDMODE        : IN    STD_LOGIC;
        RATIOMODE           : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );
        CENTERYJK_R25_N     : IN    STD_LOGIC;

        -- VIDEO OUTPUT
        PVIDEOR             : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
        PVIDEOG             : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
        PVIDEOB             : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );

        PVIDEOHS_N          : OUT   STD_LOGIC;
        PVIDEOVS_N          : OUT   STD_LOGIC;
        PVIDEOCS_N          : OUT   STD_LOGIC;

        PVIDEODHCLK         : OUT   STD_LOGIC;
        PVIDEODLCLK         : OUT   STD_LOGIC;

        BLANK_O             : OUT   STD_LOGIC;
        INTERLACEMODE       : OUT   STD_LOGIC;

        -- DISPLAY RESOLUTION (0=15KHZ, 1=31KHZ)
        DISPRESO            : IN    STD_LOGIC;

        NTSC_PAL_TYPE       : IN    STD_LOGIC;
        FORCED_V_MODE       : IN    STD_LOGIC;
        LEGACY_VGA          : IN    STD_LOGIC;
        VGA_INT_FIELD       : IN    STD_LOGIC;

        SPMAXSPR            : IN    STD_LOGIC;

        VDP_ID              : IN    STD_LOGIC_VECTOR(  4 DOWNTO 0 );
        OFFSET_Y            : IN    STD_LOGIC_VECTOR(  6 DOWNTO 0 )

        -- DEBUG OUTPUT
    --  DEBUG_OUTPUT        : OUT   STD_LOGIC_VECTOR( 15 DOWNTO 0 ) -- ★
    );
END VDP;

ARCHITECTURE RTL OF VDP IS
    COMPONENT VDP_SSG
        PORT(
            RESET                   : IN    STD_LOGIC;
            CLK21M                  : IN    STD_LOGIC;

            H_CNT                   : OUT   STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            V_CNT                   : OUT   STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            DOTSTATE                : OUT   STD_LOGIC_VECTOR(  1 DOWNTO 0 );
            EIGHTDOTSTATE           : OUT   STD_LOGIC_VECTOR(  2 DOWNTO 0 );
            PREDOTCOUNTER_X         : OUT   STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            PREDOTCOUNTER_Y         : OUT   STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            PREDOTCOUNTER_YP        : OUT   STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            PREWINDOW_Y             : OUT   STD_LOGIC;
            PREWINDOW_Y_SP          : OUT   STD_LOGIC;
            FIELD                   : OUT   STD_LOGIC;
            WINDOW_X                : OUT   STD_LOGIC;
            PVIDEODHCLK             : OUT   STD_LOGIC;
            PVIDEODLCLK             : OUT   STD_LOGIC;
            IVIDEOVS_N              : OUT   STD_LOGIC;

            HD                      : OUT   STD_LOGIC;
            VD                      : OUT   STD_LOGIC;
            HSYNC                   : OUT   STD_LOGIC;
            ENAHSYNC                : OUT   STD_LOGIC;
            V_BLANKING_START        : OUT   STD_LOGIC;

            VDPR9PALMODE            : IN    STD_LOGIC;
            REG_R9_INTERLACE_MODE   : IN    STD_LOGIC;
            REG_R9_Y_DOTS           : IN    STD_LOGIC;
            REG_R18_ADJ             : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R23_VSTART_LINE     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R25_MSK             : IN    STD_LOGIC;
            REG_R27_H_SCROLL        : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );
            REG_R25_YJK             : IN    STD_LOGIC;
            CENTERYJK_R25_N         : IN    STD_LOGIC;
            OFFSET_Y                : IN    STD_LOGIC_VECTOR(  6 DOWNTO 0 )
        );
    END COMPONENT;

    COMPONENT VDP_INTERRUPT
        PORT(
            RESET                   : IN    STD_LOGIC;
            CLK21M                  : IN    STD_LOGIC;

            H_CNT                   : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            Y_CNT                   : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            ACTIVE_LINE             : IN    STD_LOGIC;
            V_BLANKING_START        : IN    STD_LOGIC;
            CLR_VSYNC_INT           : IN    STD_LOGIC;
            CLR_HSYNC_INT           : IN    STD_LOGIC;
            REQ_VSYNC_INT_N         : OUT   STD_LOGIC;
            REQ_HSYNC_INT_N         : OUT   STD_LOGIC;
            REG_R19_HSYNC_INT_LINE  : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 )
        );
    END COMPONENT;

    COMPONENT VDP_SPRITE
        PORT(
            -- VDP CLOCK ... 21.477MHZ
            CLK21M                      : IN    STD_LOGIC;
            RESET                       : IN    STD_LOGIC;

            DOTSTATE                    : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0 );
            EIGHTDOTSTATE               : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );

            DOTCOUNTERX                 : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            DOTCOUNTERYP                : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            BWINDOW_Y                   : IN    STD_LOGIC;

            -- VDP STATUS REGISTERS OF SPRITE
            PVDPS0SPCOLLISIONINCIDENCE  : OUT   STD_LOGIC;
            PVDPS0SPOVERMAPPED          : OUT   STD_LOGIC;
            PVDPS0SPOVERMAPPEDNUM       : OUT   STD_LOGIC_VECTOR(  4 DOWNTO 0 );
            PVDPS3S4SPCOLLISIONX        : OUT   STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            PVDPS5S6SPCOLLISIONY        : OUT   STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            PVDPS0RESETREQ              : IN    STD_LOGIC;
            PVDPS0RESETACK              : OUT   STD_LOGIC;
            PVDPS5RESETREQ              : IN    STD_LOGIC;
            PVDPS5RESETACK              : OUT   STD_LOGIC;

            -- VDP REGISTERS
            REG_R1_SP_SIZE              : IN    STD_LOGIC;
            REG_R1_SP_ZOOM              : IN    STD_LOGIC;
            REG_R11R5_SP_ATR_ADDR       : IN    STD_LOGIC_VECTOR(  9 DOWNTO 0 );
            REG_R6_SP_GEN_ADDR          : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            REG_R8_COL0_ON              : IN    STD_LOGIC;
            REG_R8_SP_OFF               : IN    STD_LOGIC;
            REG_R9_Y_DOTS               : IN    STD_LOGIC;
            REG_R23_VSTART_LINE         : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R27_H_SCROLL            : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );

            SPMODE2                     : IN    STD_LOGIC;
            SPMAXSPR                    : IN    STD_LOGIC;
            VRAMINTERLEAVEMODE          : IN    STD_LOGIC;

            SPVRAMACCESSING             : OUT   STD_LOGIC;

            PRAMDAT                     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PRAMADR                     : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );

            -- JP: スプライトを描画した時に'1'になる。カラーコード0で
            -- JP: 描画する事もできるので、このビットが必要
            SPCOLOROUT                  : OUT   STD_LOGIC;

            -- OUTPUT COLOR
            SPCOLORCODE                 : OUT   STD_LOGIC_VECTOR(  3 DOWNTO 0 )
        );
    END COMPONENT;

    COMPONENT RAM
        PORT(
            ADR     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            CLK     : IN    STD_LOGIC;
            WE      : IN    STD_LOGIC;
            DBO     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            DBI     : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 )
        );
    END COMPONENT;

    COMPONENT VDP_NTSC_PAL
        PORT(
            CLK21M              : IN    STD_LOGIC;
            RESET               : IN    STD_LOGIC;
            -- MODE
            PALMODE             : IN    STD_LOGIC;
            INTERLACEMODE       : IN    STD_LOGIC;
            -- VIDEO INPUT
            VIDEORIN            : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOGIN            : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOBIN            : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOVSIN_N         : IN    STD_LOGIC;
            HCOUNTERIN          : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            VCOUNTERIN          : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            -- VIDEO OUTPUT
            VIDEOROUT           : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOGOUT           : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOBOUT           : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOHSOUT_N        : OUT   STD_LOGIC;
            VIDEOVSOUT_N        : OUT   STD_LOGIC
        );
    END COMPONENT;

    COMPONENT VDP_VGA
        PORT(
            CLK21M              : IN    STD_LOGIC;
            RESET               : IN    STD_LOGIC;
            -- VIDEO INPUT
            VIDEORIN            : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOGIN            : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOBIN            : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOVSIN_N         : IN    STD_LOGIC;
            HCOUNTERIN          : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            VCOUNTERIN          : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            -- MODE
            PALMODE             : IN    STD_LOGIC;
            INTERLACEMODE       : IN    STD_LOGIC;
            LEGACY_VGA          : IN    STD_LOGIC;
            VGA_INT_FIELD       : IN    STD_LOGIC;
            -- VIDEO OUTPUT
            VIDEOROUT           : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOGOUT           : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOBOUT           : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            VIDEOHSOUT_N        : OUT   STD_LOGIC;
            VIDEOVSOUT_N        : OUT   STD_LOGIC;
            -- HDMI SUPPORT
            BLANK_O             : OUT   STD_LOGIC;
            -- MISC
            RATIOMODE           : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 )
            );
    END COMPONENT;

    COMPONENT VDP_COMMAND
        PORT(
            RESET               : IN    STD_LOGIC;
            CLK21M              : IN    STD_LOGIC;

            VDPMODEGRAPHIC4     : IN    STD_LOGIC;
            VDPMODEGRAPHIC5     : IN    STD_LOGIC;
            VDPMODEGRAPHIC6     : IN    STD_LOGIC;
            VDPMODEGRAPHIC7     : IN    STD_LOGIC;
            VDPMODEISHIGHRES    : IN    STD_LOGIC;

            VRAMWRACK           : IN    STD_LOGIC;
            VRAMRDACK           : IN    STD_LOGIC;
            VRAMREADINGR        : IN    STD_LOGIC;
            VRAMREADINGA        : IN    STD_LOGIC;
            VRAMRDDATA          : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REGWRREQ            : IN    STD_LOGIC;
            TRCLRREQ            : IN    STD_LOGIC;
            REGNUM              : IN    STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            REGDATA             : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PREGWRACK           : OUT   STD_LOGIC;
            PTRCLRACK           : OUT   STD_LOGIC;
            PVRAMWRREQ          : OUT   STD_LOGIC;
            PVRAMRDREQ          : OUT   STD_LOGIC;
            PVRAMACCESSADDR     : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );
            PVRAMWRDATA         : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PCLR                : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );    -- R44, S#7
            PCE                 : OUT   STD_LOGIC;                          -- S#2 (BIT 0)
            PBD                 : OUT   STD_LOGIC;                          -- S#2 (BIT 4)
            PTR                 : OUT   STD_LOGIC;                          -- S#2 (BIT 7)
            PSXTMP              : OUT   STD_LOGIC_VECTOR( 10 DOWNTO 0 );    -- S#8, S#9

            CUR_VDP_COMMAND     : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 4 );

            REG_R25_CMD         : IN    STD_LOGIC
        );
    END COMPONENT;

    COMPONENT VDP_WAIT_CONTROL
        PORT(
            RESET           : IN    STD_LOGIC;
            CLK21M          : IN    STD_LOGIC;

            VDP_COMMAND     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 4 );

            VDPR9PALMODE    : IN    STD_LOGIC;      -- 0=60Hz (NTSC), 1=50Hz (PAL)
            REG_R1_DISP_ON  : IN    STD_LOGIC;      -- 0=Display Off, 1=Display On
            REG_R8_SP_OFF   : IN    STD_LOGIC;      -- 0=Sprite On, 1=Sprite Off
            REG_R9_Y_DOTS   : IN    STD_LOGIC;      -- 0=192 Lines, 1=212 Lines

            VDPSPEEDMODE    : IN    STD_LOGIC;
            DRIVE           : IN    STD_LOGIC;

            ACTIVE          : OUT   STD_LOGIC
        );
    END COMPONENT;

    COMPONENT VDP_COLORDEC
        PORT(
            RESET               : IN    STD_LOGIC;
            CLK21M              : IN    STD_LOGIC;

            DOTSTATE            : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0 );

            PPALETTEADDR_OUT    : OUT   STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            PALETTEDATARB_OUT   : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PALETTEDATAG_OUT    : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );

            VDPMODETEXT1        : IN    STD_LOGIC;
            VDPMODETEXT1Q       : IN    STD_LOGIC;
            VDPMODETEXT2        : IN    STD_LOGIC;
            VDPMODEMULTI        : IN    STD_LOGIC;
            VDPMODEMULTIQ       : IN    STD_LOGIC;
            VDPMODEGRAPHIC1     : IN    STD_LOGIC;
            VDPMODEGRAPHIC2     : IN    STD_LOGIC;
            VDPMODEGRAPHIC3     : IN    STD_LOGIC;
            VDPMODEGRAPHIC4     : IN    STD_LOGIC;
            VDPMODEGRAPHIC5     : IN    STD_LOGIC;
            VDPMODEGRAPHIC6     : IN    STD_LOGIC;
            VDPMODEGRAPHIC7     : IN    STD_LOGIC;

            WINDOW              : IN    STD_LOGIC;
            SPRITECOLOROUT      : IN    STD_LOGIC;
            COLORCODET12        : IN    STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            COLORCODEG123M      : IN    STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            COLORCODEG4567      : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            COLORCODESPRITE     : IN    STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            P_YJK_R             : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            P_YJK_G             : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            P_YJK_B             : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            P_YJK_EN            : IN    STD_LOGIC;

            PVIDEOR_VDP         : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            PVIDEOG_VDP         : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            PVIDEOB_VDP         : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );

            REG_R1_DISP_ON      : IN    STD_LOGIC;
            REG_R7_FRAME_COL    : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R8_COL0_ON      : IN    STD_LOGIC;
            REG_R25_YJK         : IN    STD_LOGIC
        );
    END COMPONENT;

    COMPONENT VDP_TEXT12
        PORT(
            -- VDP CLOCK ... 21.477MHZ
            CLK21M                      : IN    STD_LOGIC;
            RESET                       : IN    STD_LOGIC;

            DOTSTATE                    : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0 );
            DOTCOUNTERX                 : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            DOTCOUNTERY                 : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            DOTCOUNTERYP                : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );

            VDPMODETEXT1                : IN    STD_LOGIC;
            VDPMODETEXT1Q               : IN    STD_LOGIC;
            VDPMODETEXT2                : IN    STD_LOGIC;

            -- REGISTERS
            REG_R1_BL_CLKS              : IN    STD_LOGIC;
            REG_R7_FRAME_COL            : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R12_BLINK_MODE          : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R13_BLINK_PERIOD        : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R2_PT_NAM_ADDR          : IN    STD_LOGIC_VECTOR(  6 DOWNTO 0 );
            REG_R4_PT_GEN_ADDR          : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            REG_R10R3_COL_ADDR          : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );

            PRAMDAT                     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PRAMADR                     : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );
            TXVRAMREADEN                : OUT   STD_LOGIC;

            PCOLORCODE                  : OUT   STD_LOGIC_VECTOR(  3 DOWNTO 0 )
        );
    END COMPONENT;

    COMPONENT VDP_GRAPHIC123M
        PORT(
            CLK21M                      : IN    STD_LOGIC;      --  21.477MHZ
            RESET                       : IN    STD_LOGIC;

            -- CONTROL SIGNALS
            DOTSTATE                    : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0 );
            EIGHTDOTSTATE               : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );
            DOTCOUNTERX                 : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            DOTCOUNTERY                 : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );

            VDPMODEMULTI                : IN    STD_LOGIC;
            VDPMODEMULTIQ               : IN    STD_LOGIC;
            VDPMODEGRAPHIC1             : IN    STD_LOGIC;
            VDPMODEGRAPHIC2             : IN    STD_LOGIC;
            VDPMODEGRAPHIC3             : IN    STD_LOGIC;

            -- REGISTERS
            REG_R2_PT_NAM_ADDR          : IN    STD_LOGIC_VECTOR(  6 DOWNTO 0 );
            REG_R4_PT_GEN_ADDR          : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            REG_R10R3_COL_ADDR          : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            REG_R26_H_SCROLL            : IN    STD_LOGIC_VECTOR(  8 DOWNTO 3 );
            REG_R27_H_SCROLL            : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );

            PRAMDAT                     : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PRAMADR                     : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );

            PCOLORCODE                  : OUT   STD_LOGIC_VECTOR(  3 DOWNTO 0 )
        );
    END COMPONENT;

    COMPONENT VDP_GRAPHIC4567
        PORT(
            -- VDP CLOCK ... 21.477MHZ
            CLK21M                  : IN    STD_LOGIC;
            RESET                   : IN    STD_LOGIC;

            DOTSTATE                : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0 );
            EIGHTDOTSTATE           : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );
            DOTCOUNTERX             : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );
            DOTCOUNTERY             : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );

            VDPMODEGRAPHIC4         : IN    STD_LOGIC;
            VDPMODEGRAPHIC5         : IN    STD_LOGIC;
            VDPMODEGRAPHIC6         : IN    STD_LOGIC;
            VDPMODEGRAPHIC7         : IN    STD_LOGIC;

            -- REGISTERS
            REG_R1_BL_CLKS          : IN    STD_LOGIC;
            REG_R2_PT_NAM_ADDR      : IN    STD_LOGIC_VECTOR(  6 DOWNTO 0 );
            REG_R13_BLINK_PERIOD    : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R26_H_SCROLL        : IN    STD_LOGIC_VECTOR(  8 DOWNTO 3 );
            REG_R27_H_SCROLL        : IN    STD_LOGIC_VECTOR(  2 DOWNTO 0 );
            REG_R25_YAE             : IN    STD_LOGIC;
            REG_R25_YJK             : IN    STD_LOGIC;
            REG_R25_SP2             : IN    STD_LOGIC;

            PRAMDAT                 : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PRAMDATPAIR             : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PRAMADR                 : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );

            PCOLORCODE              : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );

            P_YJK_R                 : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            P_YJK_G                 : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            P_YJK_B                 : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            P_YJK_EN                : OUT   STD_LOGIC
        );
    END COMPONENT;

    COMPONENT VDP_REGISTER
        PORT(
            RESET                       : IN    STD_LOGIC;
            CLK21M                      : IN    STD_LOGIC;

            REQ                         : IN    STD_LOGIC;
            ACK                         : OUT   STD_LOGIC;
            WRT                         : IN    STD_LOGIC;
            ADR                         : IN    STD_LOGIC_VECTOR( 15 DOWNTO 0 );
            DBI                         : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            DBO                         : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );

            DOTSTATE                    : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0 );

            VDPCMDTRCLRACK              : IN    STD_LOGIC;
            VDPCMDREGWRACK              : IN    STD_LOGIC;
            HSYNC                       : IN    STD_LOGIC;

            VDPS0SPCOLLISIONINCIDENCE   : IN    STD_LOGIC;
            VDPS0SPOVERMAPPED           : IN    STD_LOGIC;
            VDPS0SPOVERMAPPEDNUM        : IN    STD_LOGIC_VECTOR(  4 DOWNTO 0 );
            SPVDPS0RESETREQ             : OUT   STD_LOGIC;
            SPVDPS0RESETACK             : IN    STD_LOGIC;
            SPVDPS5RESETREQ             : OUT   STD_LOGIC;
            SPVDPS5RESETACK             : IN    STD_LOGIC;

            VDPCMDTR                    : IN    STD_LOGIC;                          -- S#2
            VD                          : IN    STD_LOGIC;                          -- S#2
            HD                          : IN    STD_LOGIC;                          -- S#2
            VDPCMDBD                    : IN    STD_LOGIC;                          -- S#2
            FIELD                       : IN    STD_LOGIC;                          -- S#2
            VDPCMDCE                    : IN    STD_LOGIC;                          -- S#2
            VDPS3S4SPCOLLISIONX         : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );    -- S#3,S#4
            VDPS5S6SPCOLLISIONY         : IN    STD_LOGIC_VECTOR(  8 DOWNTO 0 );    -- S#5,S#6
            VDPCMDCLR                   : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );    -- R44,S#7
            VDPCMDSXTMP                 : IN    STD_LOGIC_VECTOR( 10 DOWNTO 0 );    -- S#8,S#9

            VDPVRAMACCESSDATA           : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            VDPVRAMACCESSADDRTMP        : OUT   STD_LOGIC_VECTOR( 16 DOWNTO 0 );
            VDPVRAMADDRSETREQ           : OUT   STD_LOGIC;
            VDPVRAMADDRSETACK           : IN    STD_LOGIC;
            VDPVRAMWRREQ                : OUT   STD_LOGIC;
            VDPVRAMWRACK                : IN    STD_LOGIC;
            VDPVRAMRDDATA               : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            VDPVRAMRDREQ                : OUT   STD_LOGIC;
            VDPVRAMRDACK                : IN    STD_LOGIC;

            VDPCMDREGNUM                : OUT   STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            VDPCMDREGDATA               : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            VDPCMDREGWRREQ              : OUT   STD_LOGIC;
            VDPCMDTRCLRREQ              : OUT   STD_LOGIC;

            PALETTEADDR_OUT             : IN    STD_LOGIC_VECTOR(  3 DOWNTO 0 );
            PALETTEDATARB_OUT           : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            PALETTEDATAG_OUT            : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );

            -- INTERRUPT
            CLR_VSYNC_INT               : OUT   STD_LOGIC;
            CLR_HSYNC_INT               : OUT   STD_LOGIC;
            REQ_VSYNC_INT_N             : IN    STD_LOGIC;
            REQ_HSYNC_INT_N             : IN    STD_LOGIC;

            -- REGISTER VALUE
            REG_R0_HSYNC_INT_EN         : OUT   STD_LOGIC;
            REG_R1_SP_SIZE              : OUT   STD_LOGIC;
            REG_R1_SP_ZOOM              : OUT   STD_LOGIC;
            REG_R1_BL_CLKS              : OUT   STD_LOGIC;
            REG_R1_VSYNC_INT_EN         : OUT   STD_LOGIC;
            REG_R1_DISP_ON              : OUT   STD_LOGIC;
            REG_R2_PT_NAM_ADDR          : OUT   STD_LOGIC_VECTOR(  6 DOWNTO 0 );
            REG_R4_PT_GEN_ADDR          : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            REG_R10R3_COL_ADDR          : OUT   STD_LOGIC_VECTOR( 10 DOWNTO 0 );
            REG_R11R5_SP_ATR_ADDR       : OUT   STD_LOGIC_VECTOR(  9 DOWNTO 0 );
            REG_R6_SP_GEN_ADDR          : OUT   STD_LOGIC_VECTOR(  5 DOWNTO 0 );
            REG_R7_FRAME_COL            : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R8_SP_OFF               : OUT   STD_LOGIC;
            REG_R8_COL0_ON              : OUT   STD_LOGIC;
            REG_R9_PAL_MODE             : OUT   STD_LOGIC;
            REG_R9_INTERLACE_MODE       : OUT   STD_LOGIC;
            REG_R9_Y_DOTS               : OUT   STD_LOGIC;
            REG_R12_BLINK_MODE          : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R13_BLINK_PERIOD        : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R18_ADJ                 : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R19_HSYNC_INT_LINE      : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R23_VSTART_LINE         : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
            REG_R25_CMD                 : OUT   STD_LOGIC;
            REG_R25_YAE                 : OUT   STD_LOGIC;
            REG_R25_YJK                 : OUT   STD_LOGIC;
            REG_R25_MSK                 : OUT   STD_LOGIC;
            REG_R25_SP2                 : OUT   STD_LOGIC;
            REG_R26_H_SCROLL            : OUT   STD_LOGIC_VECTOR(  8 DOWNTO 3 );
            REG_R27_H_SCROLL            : OUT   STD_LOGIC_VECTOR(  2 DOWNTO 0 );

            --  MODE
            VDPMODETEXT1                : OUT   STD_LOGIC;
            VDPMODETEXT1Q               : OUT   STD_LOGIC;
            VDPMODETEXT2                : OUT   STD_LOGIC;
            VDPMODEMULTI                : OUT   STD_LOGIC;
            VDPMODEMULTIQ               : OUT   STD_LOGIC;
            VDPMODEGRAPHIC1             : OUT   STD_LOGIC;
            VDPMODEGRAPHIC2             : OUT   STD_LOGIC;
            VDPMODEGRAPHIC3             : OUT   STD_LOGIC;
            VDPMODEGRAPHIC4             : OUT   STD_LOGIC;
            VDPMODEGRAPHIC5             : OUT   STD_LOGIC;
            VDPMODEGRAPHIC6             : OUT   STD_LOGIC;
            VDPMODEGRAPHIC7             : OUT   STD_LOGIC;
            VDPMODEISHIGHRES            : OUT   STD_LOGIC;
            SPMODE2                     : OUT   STD_LOGIC;
            VDPMODEISVRAMINTERLEAVE     : OUT   STD_LOGIC;

            -- MISC
            FORCED_V_MODE               : IN    STD_LOGIC;
            SPMAXSPR                    : IN    STD_LOGIC;
            VDP_ID                      : IN    STD_LOGIC_VECTOR(  4 DOWNTO 0 )
        );
    END COMPONENT;

    SIGNAL H_CNT                        : STD_LOGIC_VECTOR( 10 DOWNTO 0 );
    SIGNAL V_CNT                        : STD_LOGIC_VECTOR( 10 DOWNTO 0 );

    -- DISPLAY POSITIONS, ADAPTED FOR ADJUST(X,Y)
    SIGNAL ADJUST_X                     : STD_LOGIC_VECTOR(  6 DOWNTO 0 );

    -- DOT STATE REGISTER
    SIGNAL DOTSTATE                     : STD_LOGIC_VECTOR(  1 DOWNTO 0 );
    SIGNAL EIGHTDOTSTATE                : STD_LOGIC_VECTOR(  2 DOWNTO 0 );

    -- DISPLAY FIELD SIGNAL
    SIGNAL FIELD                        : STD_LOGIC;
    SIGNAL HD                           : STD_LOGIC;
    SIGNAL VD                           : STD_LOGIC;
    SIGNAL ACTIVE_LINE                  : STD_LOGIC;
    SIGNAL V_BLANKING_START             : STD_LOGIC;

    -- FOR VSYNC INTERRUPT
    SIGNAL VSYNCINT_N                   : STD_LOGIC;
    SIGNAL CLR_VSYNC_INT                : STD_LOGIC;
    SIGNAL REQ_VSYNC_INT_N              : STD_LOGIC;

    -- FOR HSYNC INTERRUPT
    SIGNAL HSYNCINT_N                   : STD_LOGIC;
    SIGNAL CLR_HSYNC_INT                : STD_LOGIC;
    SIGNAL REQ_HSYNC_INT_N              : STD_LOGIC;

    SIGNAL DVIDEOHS_N                   : STD_LOGIC;

    -- DISPLAY AREA FLAGS
    SIGNAL WINDOW                       : STD_LOGIC;
    SIGNAL WINDOW_X                     : STD_LOGIC;
    SIGNAL PREWINDOW_X                  : STD_LOGIC;
    SIGNAL PREWINDOW_Y                  : STD_LOGIC;
    SIGNAL PREWINDOW_Y_SP               : STD_LOGIC;
    SIGNAL PREWINDOW                    : STD_LOGIC;
    SIGNAL PREWINDOW_SP                 : STD_LOGIC;
    -- FOR FRAME ZONE
    SIGNAL BWINDOW_X                    : STD_LOGIC;
    SIGNAL BWINDOW_Y                    : STD_LOGIC;
    SIGNAL BWINDOW                      : STD_LOGIC;

    -- DOT COUNTER - 8 ( READING ADDR )
    SIGNAL PREDOTCOUNTER_X              : STD_LOGIC_VECTOR(  8 DOWNTO 0 );
    SIGNAL PREDOTCOUNTER_Y              : STD_LOGIC_VECTOR(  8 DOWNTO 0 );
    -- Y COUNTERS INDEPENDENT OF VERTICAL SCROLL REGISTER
    SIGNAL PREDOTCOUNTER_YP             : STD_LOGIC_VECTOR(  8 DOWNTO 0 );

    -- VDP REGISTER ACCESS
    SIGNAL VDPVRAMACCESSADDR            : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL DISPMODEVGA                  : STD_LOGIC;
    SIGNAL VDPVRAMREADINGR              : STD_LOGIC;
    SIGNAL VDPVRAMREADINGA              : STD_LOGIC;
    SIGNAL VDPR0DISPNUM                 : STD_LOGIC_VECTOR(  3 DOWNTO 1 );
    SIGNAL VDPVRAMACCESSDATA            : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL VDPVRAMACCESSADDRTMP         : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL VDPVRAMADDRSETREQ            : STD_LOGIC;
    SIGNAL VDPVRAMADDRSETACK            : STD_LOGIC;
    SIGNAL VDPVRAMWRREQ                 : STD_LOGIC;
    SIGNAL VDPVRAMWRACK                 : STD_LOGIC;
    SIGNAL VDPVRAMRDDATA                : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL VDPVRAMRDREQ                 : STD_LOGIC;
    SIGNAL VDPVRAMRDACK                 : STD_LOGIC;
    SIGNAL VDPR9PALMODE                 : STD_LOGIC;

    SIGNAL REG_R0_HSYNC_INT_EN          : STD_LOGIC;
    SIGNAL REG_R1_SP_SIZE               : STD_LOGIC;
    SIGNAL REG_R1_SP_ZOOM               : STD_LOGIC;
    SIGNAL REG_R1_BL_CLKS               : STD_LOGIC;
    SIGNAL REG_R1_VSYNC_INT_EN          : STD_LOGIC;
    SIGNAL REG_R1_DISP_ON               : STD_LOGIC;
    SIGNAL REG_R2_PT_NAM_ADDR           : STD_LOGIC_VECTOR(  6 DOWNTO 0 );
    SIGNAL REG_R4_PT_GEN_ADDR           : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL REG_R10R3_COL_ADDR           : STD_LOGIC_VECTOR( 10 DOWNTO 0 );
    SIGNAL REG_R11R5_SP_ATR_ADDR        : STD_LOGIC_VECTOR(  9 DOWNTO 0 );
    SIGNAL REG_R6_SP_GEN_ADDR           : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL REG_R7_FRAME_COL             : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL REG_R8_SP_OFF                : STD_LOGIC;
    SIGNAL REG_R8_COL0_ON               : STD_LOGIC;
    SIGNAL REG_R9_PAL_MODE              : STD_LOGIC;
    SIGNAL REG_R9_INTERLACE_MODE        : STD_LOGIC;
    SIGNAL REG_R9_Y_DOTS                : STD_LOGIC;
    SIGNAL REG_R12_BLINK_MODE           : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL REG_R13_BLINK_PERIOD         : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL REG_R18_ADJ                  : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL REG_R19_HSYNC_INT_LINE       : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL REG_R23_VSTART_LINE          : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL REG_R25_CMD                  : STD_LOGIC;
    SIGNAL REG_R25_YAE                  : STD_LOGIC;
    SIGNAL REG_R25_YJK                  : STD_LOGIC;
    SIGNAL REG_R25_MSK                  : STD_LOGIC;
    SIGNAL REG_R25_SP2                  : STD_LOGIC;
    SIGNAL REG_R26_H_SCROLL             : STD_LOGIC_VECTOR(  8 DOWNTO 3 );
    SIGNAL REG_R27_H_SCROLL             : STD_LOGIC_VECTOR(  2 DOWNTO 0 );

    SIGNAL TEXT_MODE                    : STD_LOGIC;    -- TEXT MODE 1, 2 or 1Q
    SIGNAL VDPMODETEXT1                 : STD_LOGIC;    -- TEXT MODE 1      (SCREEN0 WIDTH 40)
    SIGNAL VDPMODETEXT1Q                : STD_LOGIC;    -- TEXT MODE 1      (??)
    SIGNAL VDPMODETEXT2                 : STD_LOGIC;    -- TEXT MODE 2      (SCREEN0 WIDTH 80)
    SIGNAL VDPMODEMULTI                 : STD_LOGIC;    -- MULTICOLOR MODE  (SCREEN3)
    SIGNAL VDPMODEMULTIQ                : STD_LOGIC;    -- MULTICOLOR MODE  (??)
    SIGNAL VDPMODEGRAPHIC1              : STD_LOGIC;    -- GRAPHIC MODE 1   (SCREEN1)
    SIGNAL VDPMODEGRAPHIC2              : STD_LOGIC;    -- GRAPHIC MODE 2   (SCREEN2)
    SIGNAL VDPMODEGRAPHIC3              : STD_LOGIC;    -- GRAPHIC MODE 2   (SCREEN4)
    SIGNAL VDPMODEGRAPHIC4              : STD_LOGIC;    -- GRAPHIC MODE 4   (SCREEN5)
    SIGNAL VDPMODEGRAPHIC5              : STD_LOGIC;    -- GRAPHIC MODE 5   (SCREEN6)
    SIGNAL VDPMODEGRAPHIC6              : STD_LOGIC;    -- GRAPHIC MODE 6   (SCREEN7)
    SIGNAL VDPMODEGRAPHIC7              : STD_LOGIC;    -- GRAPHIC MODE 7   (SCREEN8,10,11,12)
    SIGNAL VDPMODEISHIGHRES             : STD_LOGIC;    -- TRUE WHEN MODE GRAPHIC5, 6
    SIGNAL VDPMODEISVRAMINTERLEAVE      : STD_LOGIC;    -- TRUE WHEN MODE GRAPHIC6, 7

    -- FOR TEXT 1 AND 2
    SIGNAL PRAMADRT12                   : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL COLORCODET12                 : STD_LOGIC_VECTOR(  3 DOWNTO 0 );
    SIGNAL TXVRAMREADEN                 : STD_LOGIC;

    -- FOR GRAPHIC 1,2,3 AND MULTI COLOR
    SIGNAL PRAMADRG123M                 : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL COLORCODEG123M               : STD_LOGIC_VECTOR(  3 DOWNTO 0 );

    -- FOR GRAPHIC 4,5,6,7
    SIGNAL PRAMADRG4567                 : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL COLORCODEG4567               : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL YJK_R                        : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL YJK_G                        : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL YJK_B                        : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL YJK_EN                       : STD_LOGIC;

    -- SPRITE
    SIGNAL SPMODE2                      : STD_LOGIC;
    SIGNAL SPVRAMACCESSING              : STD_LOGIC;
    SIGNAL PRAMADRSPRITE                : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL SPRITECOLOROUT               : STD_LOGIC;
    SIGNAL COLORCODESPRITE              : STD_LOGIC_VECTOR(  3 DOWNTO 0 );
    SIGNAL VDPS0SPCOLLISIONINCIDENCE    : STD_LOGIC;
    SIGNAL VDPS0SPOVERMAPPED            : STD_LOGIC;
    SIGNAL VDPS0SPOVERMAPPEDNUM         : STD_LOGIC_VECTOR(  4 DOWNTO 0 );
    SIGNAL VDPS3S4SPCOLLISIONX          : STD_LOGIC_VECTOR(  8 DOWNTO 0 );
    SIGNAL VDPS5S6SPCOLLISIONY          : STD_LOGIC_VECTOR(  8 DOWNTO 0 );
    SIGNAL SPVDPS0RESETREQ              : STD_LOGIC;
    SIGNAL SPVDPS0RESETACK              : STD_LOGIC;
    SIGNAL SPVDPS5RESETREQ              : STD_LOGIC;
    SIGNAL SPVDPS5RESETACK              : STD_LOGIC;

    -- PALETTE REGISTERS
    SIGNAL PALETTEADDR_OUT              : STD_LOGIC_VECTOR(  3 DOWNTO 0 );
    SIGNAL PALETTEDATARB_OUT            : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL PALETTEDATAG_OUT             : STD_LOGIC_VECTOR(  7 DOWNTO 0 );

    -- VDP COMMAND SIGNALS - CAN BE READ & SET BY CPU
    SIGNAL VDPCMDCLR                    : STD_LOGIC_VECTOR(  7 DOWNTO 0 );  -- R44, S#7
    -- VDP COMMAND SIGNALS - CAN BE READ BY CPU
    SIGNAL VDPCMDCE                     : STD_LOGIC;                        -- S#2 (BIT 0)
    SIGNAL VDPCMDBD                     : STD_LOGIC;                        -- S#2 (BIT 4)
    SIGNAL VDPCMDTR                     : STD_LOGIC;                        -- S#2 (BIT 7)
    SIGNAL VDPCMDSXTMP                  : STD_LOGIC_VECTOR( 10 DOWNTO 0 );  -- S#8, S#9

    SIGNAL VDPCMDREGNUM                 : STD_LOGIC_VECTOR(  3 DOWNTO 0 );
    SIGNAL VDPCMDREGDATA                : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL VDPCMDREGWRACK               : STD_LOGIC;
    SIGNAL VDPCMDTRCLRACK               : STD_LOGIC;
    SIGNAL VDPCMDVRAMWRACK              : STD_LOGIC;
    SIGNAL VDPCMDVRAMRDACK              : STD_LOGIC;
    SIGNAL VDPCMDVRAMREADINGR           : STD_LOGIC;
    SIGNAL VDPCMDVRAMREADINGA           : STD_LOGIC;
    SIGNAL VDPCMDVRAMRDDATA             : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL VDPCMDREGWRREQ               : STD_LOGIC;
    SIGNAL VDPCMDTRCLRREQ               : STD_LOGIC;
    SIGNAL VDPCMDVRAMWRREQ              : STD_LOGIC;
    SIGNAL VDPCMDVRAMRDREQ              : STD_LOGIC;
    SIGNAL VDPCMDVRAMACCESSADDR         : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL VDPCMDVRAMWRDATA             : STD_LOGIC_VECTOR(  7 DOWNTO 0 );

    SIGNAL VDP_COMMAND_DRIVE            : STD_LOGIC;
    SIGNAL VDP_COMMAND_ACTIVE           : STD_LOGIC;
    SIGNAL CUR_VDP_COMMAND              : STD_LOGIC_VECTOR(  7 DOWNTO 4 );

    -- VIDEO OUTPUT SIGNALS
    SIGNAL IVIDEOR                      : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOG                      : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOB                      : STD_LOGIC_VECTOR(  5 DOWNTO 0 );

    SIGNAL IVIDEOR_VDP                  : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOG_VDP                  : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOB_VDP                  : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOVS_N                   : STD_LOGIC;

    SIGNAL IVIDEOR_NTSC_PAL             : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOG_NTSC_PAL             : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOB_NTSC_PAL             : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOHS_N_NTSC_PAL          : STD_LOGIC;
    SIGNAL IVIDEOVS_N_NTSC_PAL          : STD_LOGIC;

    SIGNAL IVIDEOR_VGA                  : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOG_VGA                  : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOB_VGA                  : STD_LOGIC_VECTOR(  5 DOWNTO 0 );
    SIGNAL IVIDEOHS_N_VGA               : STD_LOGIC;
    SIGNAL IVIDEOVS_N_VGA               : STD_LOGIC;

    SIGNAL IRAMADR                      : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
    SIGNAL PRAMDAT                      : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
    SIGNAL XRAMSEL                      : STD_LOGIC;
    SIGNAL PRAMDATPAIR                  : STD_LOGIC_VECTOR(  7 DOWNTO 0 );

    SIGNAL HSYNC                        : STD_LOGIC;
    SIGNAL ENAHSYNC                     : STD_LOGIC;

    CONSTANT VRAM_ACCESS_IDLE           : INTEGER := 0;
    CONSTANT VRAM_ACCESS_DRAW           : INTEGER := 1;
    CONSTANT VRAM_ACCESS_CPUW           : INTEGER := 2;
    CONSTANT VRAM_ACCESS_CPUR           : INTEGER := 3;
    CONSTANT VRAM_ACCESS_SPRT           : INTEGER := 4;
    CONSTANT VRAM_ACCESS_VDPW           : INTEGER := 5;
    CONSTANT VRAM_ACCESS_VDPR           : INTEGER := 6;
    CONSTANT VRAM_ACCESS_VDPS           : INTEGER := 7;
BEGIN

    PRAMADR     <=  IRAMADR;
    XRAMSEL     <=  IRAMADR(16);
    PRAMDAT     <=  PRAMDBI(  7 DOWNTO 0 )  WHEN( XRAMSEL = '0' )ELSE
                    PRAMDBI( 15 DOWNTO 8 );
    PRAMDATPAIR <=  PRAMDBI(  7 DOWNTO 0 )  WHEN( XRAMSEL = '1' )ELSE
                    PRAMDBI( 15 DOWNTO 8 );

    ----------------------------------------------------------------
    -- DISPLAY COMPONENTS
    ----------------------------------------------------------------
    INTERLACEMODE   <=  REG_R9_INTERLACE_MODE;
    DISPMODEVGA     <=  DISPRESO;   -- DISPLAY RESOLUTION (0=15KHZ, 1=31KHZ)

--  VDPR9PALMODE    <=  REG_R9_PAL_MODE     WHEN( NTSC_PAL_TYPE = '1' AND LEGACY_VGA = '0' )ELSE
    VDPR9PALMODE    <=  REG_R9_PAL_MODE     WHEN( NTSC_PAL_TYPE = '1' )ELSE
                        FORCED_V_MODE;

    IVIDEOR <=  (OTHERS => '0') WHEN( BWINDOW = '0' )ELSE
                IVIDEOR_VDP;
    IVIDEOG <=  (OTHERS => '0') WHEN( BWINDOW = '0' )ELSE
                IVIDEOG_VDP;
    IVIDEOB <=  (OTHERS => '0') WHEN( BWINDOW = '0' )ELSE
                IVIDEOB_VDP;

    U_VDP_NTSC_PAL: VDP_NTSC_PAL
    PORT MAP(
        CLK21M              => CLK21M,
        RESET               => RESET,
        PALMODE             => VDPR9PALMODE,
        INTERLACEMODE       => REG_R9_INTERLACE_MODE,
        VIDEORIN            => IVIDEOR,
        VIDEOGIN            => IVIDEOG,
        VIDEOBIN            => IVIDEOB,
        VIDEOVSIN_N         => IVIDEOVS_N,
        HCOUNTERIN          => H_CNT,
        VCOUNTERIN          => V_CNT,
        VIDEOROUT           => IVIDEOR_NTSC_PAL,
        VIDEOGOUT           => IVIDEOG_NTSC_PAL,
        VIDEOBOUT           => IVIDEOB_NTSC_PAL,
        VIDEOHSOUT_N        => IVIDEOHS_N_NTSC_PAL,
        VIDEOVSOUT_N        => IVIDEOVS_N_NTSC_PAL
    );

    U_VDP_VGA: VDP_VGA
    PORT MAP(
        CLK21M              => CLK21M,
        RESET               => RESET,
        VIDEORIN            => IVIDEOR,
        VIDEOGIN            => IVIDEOG,
        VIDEOBIN            => IVIDEOB,
        VIDEOVSIN_N         => IVIDEOVS_N,
        HCOUNTERIN          => H_CNT,
        VCOUNTERIN          => V_CNT,
        PALMODE             => VDPR9PALMODE,
        INTERLACEMODE       => REG_R9_INTERLACE_MODE,
        LEGACY_VGA          => LEGACY_VGA,
        VGA_INT_FIELD       => VGA_INT_FIELD,
        VIDEOROUT           => IVIDEOR_VGA,
        VIDEOGOUT           => IVIDEOG_VGA,
        VIDEOBOUT           => IVIDEOB_VGA,
        VIDEOHSOUT_N        => IVIDEOHS_N_VGA,
        VIDEOVSOUT_N        => IVIDEOVS_N_VGA,
        BLANK_O             => BLANK_O,
        RATIOMODE           => RATIOMODE
    );

    -- CHANGE DISPLAY MODE BY EXTERNAL INPUT PORT.
    PVIDEOR     <=  IVIDEOR_NTSC_PAL WHEN( DISPMODEVGA = '0' )ELSE
                    IVIDEOR_VGA;
    PVIDEOG     <=  IVIDEOG_NTSC_PAL WHEN( DISPMODEVGA = '0' )ELSE
                    IVIDEOG_VGA;
    PVIDEOB     <=  IVIDEOB_NTSC_PAL WHEN( DISPMODEVGA = '0' )ELSE
                    IVIDEOB_VGA;

    -- H SYNC SIGNAL
    PVIDEOHS_N  <=  IVIDEOHS_N_NTSC_PAL WHEN( DISPMODEVGA = '0' )ELSE
                    IVIDEOHS_N_VGA;
    -- V SYNC SIGNAL
    PVIDEOVS_N  <=  IVIDEOVS_N_NTSC_PAL WHEN( DISPMODEVGA = '0' )ELSE
                    IVIDEOVS_N_VGA;

    -- THESE SIGNALS BELOW ARE OUTPUT DIRECTLY REGARDLESS OF DISPLAY MODE.
    PVIDEOCS_N  <= NOT (IVIDEOHS_N_NTSC_PAL XOR IVIDEOVS_N_NTSC_PAL);

    -----------------------------------------------------------------------------
    -- INTERRUPT
    -----------------------------------------------------------------------------

    -- VSYNC INTERRUPT
    VSYNCINT_N  <=  '1' WHEN( REG_R1_VSYNC_INT_EN = '0' )ELSE
                    REQ_VSYNC_INT_N;

    -- HSYNC INTERRUPT
    HSYNCINT_N  <=  '1' WHEN( REG_R0_HSYNC_INT_EN = '0' OR ENAHSYNC = '0' )ELSE
                    REQ_HSYNC_INT_N;

    INT_N       <=  '0' WHEN( VSYNCINT_N = '0' OR HSYNCINT_N = '0' )ELSE
--                  'Z';    -- OCM original setting
                    '1';    -- MIST board ( http://github.com/robinsonb5/OneChipMSX )

    U_INTERRUPT: VDP_INTERRUPT
    PORT MAP (
        RESET                   => RESET                            ,
        CLK21M                  => CLK21M                           ,

        H_CNT                   => H_CNT                            ,
        Y_CNT                   => PREDOTCOUNTER_Y(  7 DOWNTO 0 )   ,
        ACTIVE_LINE             => ACTIVE_LINE                      ,
        V_BLANKING_START        => V_BLANKING_START                 ,
        CLR_VSYNC_INT           => CLR_VSYNC_INT                    ,
        CLR_HSYNC_INT           => CLR_HSYNC_INT                    ,
        REQ_VSYNC_INT_N         => REQ_VSYNC_INT_N                  ,
        REQ_HSYNC_INT_N         => REQ_HSYNC_INT_N                  ,
        REG_R19_HSYNC_INT_LINE  => REG_R19_HSYNC_INT_LINE
    );

    PROCESS( CLK21M )
    BEGIN
        IF( CLK21M'EVENT AND CLK21M = '1' )THEN                                                         -- Modified by KdL, 2025/Jan/12th
            IF( ((VDPMODEGRAPHIC2 = '1' OR  VDPMODEGRAPHIC3 = '1') AND PREDOTCOUNTER_X = 231) OR        -- Calibrated the delay of the split-screen cutoff for Screen2/4
                ((VDPMODEGRAPHIC2 = '0' AND VDPMODEGRAPHIC3 = '0') AND PREDOTCOUNTER_X = 255) )THEN
                ACTIVE_LINE <= '1';
            ELSE
                ACTIVE_LINE <= '0';
            END IF;
        END IF;
    END PROCESS;

    -----------------------------------------------------------------------------
    -- SYNCHRONOUS SIGNAL GENERATOR
    -----------------------------------------------------------------------------
    U_SSG: VDP_SSG
    PORT MAP(
        RESET                   => RESET                    ,
        CLK21M                  => CLK21M                   ,

        H_CNT                   => H_CNT                    ,
        V_CNT                   => V_CNT                    ,
        DOTSTATE                => DOTSTATE                 ,
        EIGHTDOTSTATE           => EIGHTDOTSTATE            ,
        PREDOTCOUNTER_X         => PREDOTCOUNTER_X          ,
        PREDOTCOUNTER_Y         => PREDOTCOUNTER_Y          ,
        PREDOTCOUNTER_YP        => PREDOTCOUNTER_YP         ,
        PREWINDOW_Y             => PREWINDOW_Y              ,
        PREWINDOW_Y_SP          => PREWINDOW_Y_SP           ,
        FIELD                   => FIELD                    ,
        WINDOW_X                => WINDOW_X                 ,
        PVIDEODHCLK             => PVIDEODHCLK              ,
        PVIDEODLCLK             => PVIDEODLCLK              ,
        IVIDEOVS_N              => IVIDEOVS_N               ,

        HD                      => HD                       ,
        VD                      => VD                       ,
        HSYNC                   => HSYNC                    ,
        ENAHSYNC                => ENAHSYNC                 ,
        V_BLANKING_START        => V_BLANKING_START         ,

        VDPR9PALMODE            => VDPR9PALMODE             ,
        REG_R9_INTERLACE_MODE   => REG_R9_INTERLACE_MODE    ,
        REG_R9_Y_DOTS           => REG_R9_Y_DOTS            ,
        REG_R18_ADJ             => REG_R18_ADJ              ,
        REG_R23_VSTART_LINE     => REG_R23_VSTART_LINE      ,
        REG_R25_MSK             => REG_R25_MSK              ,
        REG_R27_H_SCROLL        => REG_R27_H_SCROLL         ,
        REG_R25_YJK             => REG_R25_YJK              ,
        CENTERYJK_R25_N         => CENTERYJK_R25_N          ,
        OFFSET_Y                => OFFSET_Y
    );

    -- GENERATE BWINDOW
    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            BWINDOW_X <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            IF( H_CNT = 200 ) THEN
                BWINDOW_X <= '1';
            ELSIF( H_CNT = CLOCKS_PER_LINE-1-1 )THEN
                BWINDOW_X <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            BWINDOW_Y <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            IF( REG_R9_INTERLACE_MODE='0' ) THEN
                -- NON-INTERLACE
                -- 3+3+16 = 19
                IF( (V_CNT = 20*2) OR
                        ((V_CNT = 524+20*2) AND (VDPR9PALMODE = '0')) OR
                        ((V_CNT = 626+20*2) AND (VDPR9PALMODE = '1')) ) THEN
                    BWINDOW_Y <= '1';
                ELSIF(  ((V_CNT = 524) AND (VDPR9PALMODE = '0')) OR
                        ((V_CNT = 626) AND (VDPR9PALMODE = '1')) OR
                         (V_CNT = 0) ) THEN
                    BWINDOW_Y <= '0';
                END IF;
            ELSE
                -- INTERLACE
                IF( (V_CNT = 20*2) OR
                        -- +1 SHOULD BE NEEDED.
                        -- BECAUSE ODD FIELD'S START IS DELAYED HALF LINE.
                        -- SO THE START POSITION OF DISPLAY TIME SHOULD BE
                        -- DELAYED MORE HALF LINE.
                        ((V_CNT = 525+20*2 + 1) AND (VDPR9PALMODE = '0')) OR
                        ((V_CNT = 625+20*2 + 1) AND (VDPR9PALMODE = '1')) ) THEN
                    BWINDOW_Y <= '1';
                ELSIF(  ((V_CNT = 525) AND (VDPR9PALMODE = '0')) OR
                        ((V_CNT = 625) AND (VDPR9PALMODE = '1')) OR
                         (V_CNT = 0) ) THEN
                    BWINDOW_Y <= '0';
                END IF;
            END IF;

        END IF;
    END PROCESS;

    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            BWINDOW <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            BWINDOW <= BWINDOW_X AND BWINDOW_Y;
        END IF;
    END PROCESS;

    -- GENERATE PREWINDOW, WINDOW
    WINDOW      <=  WINDOW_X    AND PREWINDOW_Y;
    PREWINDOW   <=  PREWINDOW_X AND PREWINDOW_Y;

    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            PREWINDOW_X <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            IF( (H_CNT = ("00" & (OFFSET_X + LED_TV_X_NTSC - ((REG_R25_MSK AND (NOT CENTERYJK_R25_N)) & "00") + 4) & "10") AND REG_R25_YJK = '1' AND CENTERYJK_R25_N = '1' AND VDPR9PALMODE = '0') OR
                (H_CNT = ("00" & (OFFSET_X + LED_TV_X_NTSC - ((REG_R25_MSK AND (NOT CENTERYJK_R25_N)) & "00")    ) & "10") AND (REG_R25_YJK = '0' OR CENTERYJK_R25_N = '0') AND VDPR9PALMODE = '0') OR
                (H_CNT = ("00" & (OFFSET_X + LED_TV_X_PAL - ((REG_R25_MSK AND (NOT CENTERYJK_R25_N)) & "00") + 4) & "10") AND REG_R25_YJK = '1' AND CENTERYJK_R25_N = '1' AND VDPR9PALMODE = '1') OR
                (H_CNT = ("00" & (OFFSET_X + LED_TV_X_PAL - ((REG_R25_MSK AND (NOT CENTERYJK_R25_N)) & "00")    ) & "10") AND (REG_R25_YJK = '0' OR CENTERYJK_R25_N = '0') AND VDPR9PALMODE = '1') )THEN
                -- HOLD
            ELSIF( H_CNT(1 DOWNTO 0) = "10") THEN
                IF( PREDOTCOUNTER_X = "111111111" ) THEN
                    -- JP: PREDOTCOUNTER_X が -1から0にカウントアップする時にWINDOWを1にする
                    PREWINDOW_X <= '1';
                ELSIF( PREDOTCOUNTER_X = "011111111" ) THEN
                    PREWINDOW_X <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ------------------------------------------------------------------------------
    -- MAIN PROCESS
    ------------------------------------------------------------------------------
    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            VDPVRAMRDDATA   <= (OTHERS => '0');
            VDPVRAMREADINGA <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            IF( DOTSTATE = "01" )THEN
                IF( VDPVRAMREADINGR /= VDPVRAMREADINGA ) THEN
                    VDPVRAMRDDATA   <= PRAMDAT;
                    VDPVRAMREADINGA <= NOT VDPVRAMREADINGA;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            VDPCMDVRAMRDDATA    <= (OTHERS => '0');
            VDPCMDVRAMRDACK     <= '0';
            VDPCMDVRAMREADINGA  <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            IF( DOTSTATE = "01" )THEN
                IF( VDPCMDVRAMREADINGR /= VDPCMDVRAMREADINGA )THEN
                    VDPCMDVRAMRDDATA    <= PRAMDAT;
                    VDPCMDVRAMRDACK     <= NOT VDPCMDVRAMRDACK;
                    VDPCMDVRAMREADINGA  <= NOT VDPCMDVRAMREADINGA;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    TEXT_MODE <= VDPMODETEXT1 OR VDPMODETEXT1Q OR VDPMODETEXT2;

    PROCESS( RESET, CLK21M )
        VARIABLE VDPVRAMACCESSADDRV : STD_LOGIC_VECTOR( 16 DOWNTO 0 );
        VARIABLE VRAMACCESSSWITCH   : INTEGER RANGE 0 TO 7;
    BEGIN
        IF( RESET = '1' )THEN

            IRAMADR <= (OTHERS => '1');
            PRAMDBO <= (OTHERS => 'Z');
            PRAMOE_N <= '1';
            PRAMWE_N <= '1';

            VDPVRAMREADINGR <= '0';

            VDPVRAMRDACK <= '0';
            VDPVRAMWRACK <= '0';
            VDPVRAMADDRSETACK <= '0';
            VDPVRAMACCESSADDR <= (OTHERS => '0');

            VDPCMDVRAMWRACK <= '0';
            VDPCMDVRAMREADINGR <= '0';
            VDP_COMMAND_DRIVE <= '0';
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN

            ------------------------------------------
            -- MAIN STATE
            ------------------------------------------
            --
            -- VRAM ACCESS ARBITER.
            --
            -- VRAMアクセスタイミングを、EIGHTDOTSTATE によって制御している
            IF( DOTSTATE = "10" ) THEN
                IF( (PREWINDOW = '1') AND (REG_R1_DISP_ON = '1') AND
                    ((EIGHTDOTSTATE="000") OR (EIGHTDOTSTATE="001") OR (EIGHTDOTSTATE="010") OR
                     (EIGHTDOTSTATE="011") OR (EIGHTDOTSTATE="100")) ) THEN
                    --  EIGHTDOTSTATE が 0～4 で、表示中の場合
                    VRAMACCESSSWITCH := VRAM_ACCESS_DRAW;
                ELSIF( (PREWINDOW = '1') AND (REG_R1_DISP_ON = '1') AND
                        (TXVRAMREADEN = '1')) THEN
                    --  EIGHTDOTSTATE が 5～7 で、表示中で、テキストモードの場合
                    VRAMACCESSSWITCH := VRAM_ACCESS_DRAW;
                ELSIF( (PREWINDOW_X = '1') AND (PREWINDOW_Y_SP = '1') AND (SPVRAMACCESSING = '1') AND
                        (EIGHTDOTSTATE="101") AND (TEXT_MODE = '0') ) THEN
                    -- FOR SPRITE Y-TESTING
                    VRAMACCESSSWITCH := VRAM_ACCESS_SPRT;
                ELSIF( (PREWINDOW_X = '0') AND (PREWINDOW_Y_SP = '1') AND (SPVRAMACCESSING = '1') AND
                        (TEXT_MODE = '0') AND
                        ((EIGHTDOTSTATE="000") OR (EIGHTDOTSTATE="001") OR (EIGHTDOTSTATE="010") OR
                        (EIGHTDOTSTATE="011") OR (EIGHTDOTSTATE="100") OR (EIGHTDOTSTATE="101")) ) THEN
                    -- FOR SPRITE PREPAREING
                    VRAMACCESSSWITCH := VRAM_ACCESS_SPRT;
                ELSIF( VDPVRAMWRREQ /= VDPVRAMWRACK )THEN
                    -- VRAM WRITE REQUEST BY CPU
                    VRAMACCESSSWITCH := VRAM_ACCESS_CPUW;
                ELSIF( VDPVRAMRDREQ /= VDPVRAMRDACK )THEN
                    -- VRAM READ REQUEST BY CPU
                    VRAMACCESSSWITCH := VRAM_ACCESS_CPUR;
--              ELSIF( EIGHTDOTSTATE="111" )THEN
                ELSE
                    -- VDP COMMAND
                    IF( VDP_COMMAND_ACTIVE = '1' )THEN
                        IF( VDPCMDVRAMWRREQ /= VDPCMDVRAMWRACK )THEN
                            VRAMACCESSSWITCH := VRAM_ACCESS_VDPW;
                        ELSIF( VDPCMDVRAMRDREQ /= VDPCMDVRAMRDACK )THEN
                            VRAMACCESSSWITCH := VRAM_ACCESS_VDPR;
                        ELSE
                            VRAMACCESSSWITCH := VRAM_ACCESS_VDPS;
                        END IF;
                    ELSE
                        VRAMACCESSSWITCH := VRAM_ACCESS_VDPS;
                    END IF;
                END IF;
            ELSE
                VRAMACCESSSWITCH := VRAM_ACCESS_DRAW;
            END IF;

            IF( VRAMACCESSSWITCH = VRAM_ACCESS_VDPW OR
                VRAMACCESSSWITCH = VRAM_ACCESS_VDPR OR
                VRAMACCESSSWITCH = VRAM_ACCESS_VDPS )THEN
                VDP_COMMAND_DRIVE <= '1';
            ELSE
                VDP_COMMAND_DRIVE <= '0';
            END IF;

            --
            -- VRAM ACCESS ADDRESS SWITCH
            --
            IF( VRAMACCESSSWITCH = VRAM_ACCESS_CPUW )THEN
                -- VRAM WRITE BY CPU
                -- JP: GRAPHIC6,7ではVRAM上のアドレスと RAM上のアドレスの関係が
                -- JP: 他の画面モードと異るので注意
                IF( (VDPMODEGRAPHIC6 = '1') OR (VDPMODEGRAPHIC7 = '1') )THEN
                    IRAMADR <= VDPVRAMACCESSADDR(0) & VDPVRAMACCESSADDR(16 DOWNTO 1);
                ELSE
                    IRAMADR <= VDPVRAMACCESSADDR;
                END IF;
                IF( (VDPMODETEXT1 = '1') OR (VDPMODETEXT1Q = '1') OR (VDPMODEMULTI = '1') OR (VDPMODEMULTIQ = '1') OR
                    (VDPMODEGRAPHIC1 = '1') OR (VDPMODEGRAPHIC2 = '1') ) THEN
                    VDPVRAMACCESSADDR(13 DOWNTO 0) <= VDPVRAMACCESSADDR(13 DOWNTO 0) + 1;
                ELSE
                    VDPVRAMACCESSADDR <= VDPVRAMACCESSADDR + 1;
                END IF;
                PRAMDBO <= VDPVRAMACCESSDATA;
                PRAMOE_N <= '1';
                PRAMWE_N <= '0';
                VDPVRAMWRACK <= NOT VDPVRAMWRACK;
            ELSIF( VRAMACCESSSWITCH = VRAM_ACCESS_CPUR ) THEN
                -- VRAM READ BY CPU
                IF( VDPVRAMADDRSETREQ /= VDPVRAMADDRSETACK ) THEN
                    VDPVRAMACCESSADDRV := VDPVRAMACCESSADDRTMP;
                    -- CLEAR VRAM ADDRESS SET REQUEST SIGNAL
                    VDPVRAMADDRSETACK <= NOT VDPVRAMADDRSETACK;
                ELSE
                    VDPVRAMACCESSADDRV := VDPVRAMACCESSADDR;
                END IF;

                -- JP: GRAPHIC6,7ではVRAM上のアドレスと RAM上のアドレスの関係が
                -- JP: 他の画面モードと異るので注意
                IF( (VDPMODEGRAPHIC6 = '1') OR (VDPMODEGRAPHIC7 = '1') )THEN
                    IRAMADR <= VDPVRAMACCESSADDRV(0) & VDPVRAMACCESSADDRV(16 DOWNTO 1);
                ELSE
                    IRAMADR <= VDPVRAMACCESSADDRV;
                END IF;
                IF( (VDPMODETEXT1 = '1') OR (VDPMODETEXT1Q = '1') OR (VDPMODEMULTI = '1') OR (VDPMODEMULTIQ = '1') OR
                    (VDPMODEGRAPHIC1 = '1') OR (VDPMODEGRAPHIC2 = '1') )THEN
                    VDPVRAMACCESSADDR(13 DOWNTO 0) <= VDPVRAMACCESSADDRV(13 DOWNTO 0) + 1;
                ELSE
                    VDPVRAMACCESSADDR <= VDPVRAMACCESSADDRV + 1;
                END IF;
                PRAMDBO <= (OTHERS => 'Z');
                PRAMOE_N <= '0';
                PRAMWE_N <= '1';
                VDPVRAMRDACK <= NOT VDPVRAMRDACK;
                VDPVRAMREADINGR <= NOT VDPVRAMREADINGA;
            ELSIF( VRAMACCESSSWITCH = VRAM_ACCESS_VDPW )THEN
                -- VRAM WRITE BY VDP COMMAND
                -- VDP COMMAND WRITE VRAM.
                -- JP: GRAPHIC6,7ではアドレスと RAM上の位置が他の画面モードと
                -- JP: 異るので注意
                IF( (VDPMODEGRAPHIC6 = '1') OR (VDPMODEGRAPHIC7 = '1') )THEN
                    IRAMADR <= VDPCMDVRAMACCESSADDR(0) & VDPCMDVRAMACCESSADDR(16 DOWNTO 1);
                ELSE
                    IRAMADR <= VDPCMDVRAMACCESSADDR;
                END IF;
                PRAMDBO <= VDPCMDVRAMWRDATA;
                PRAMOE_N <= '1';
                PRAMWE_N <= '0';
                VDPCMDVRAMWRACK <= NOT VDPCMDVRAMWRACK;
            ELSIF( VRAMACCESSSWITCH = VRAM_ACCESS_VDPR )THEN
                -- VRAM READ BY VDP COMMAND
                -- JP: GRAPHIC6,7ではアドレスと RAM上の位置が他の画面モードと
                -- JP: 異るので注意
                IF( (VDPMODEGRAPHIC6 = '1') OR (VDPMODEGRAPHIC7 = '1') )THEN
                    IRAMADR <= VDPCMDVRAMACCESSADDR(0) & VDPCMDVRAMACCESSADDR(16 DOWNTO 1);
                ELSE
                    IRAMADR <= VDPCMDVRAMACCESSADDR;
                END IF;
                PRAMDBO <= (OTHERS => 'Z');
                PRAMOE_N <= '0';
                PRAMWE_N <= '1';
                VDPCMDVRAMREADINGR <= NOT VDPCMDVRAMREADINGA;
            ELSIF( VRAMACCESSSWITCH = VRAM_ACCESS_SPRT )THEN
                -- VRAM READ BY SPRITE MODULE
                IRAMADR <= PRAMADRSPRITE;
                PRAMOE_N <= '0';
                PRAMWE_N <= '1';
                PRAMDBO <= (OTHERS => 'Z');
            ELSE
                -- VRAM_ACCESS_DRAW
                -- VRAM READ FOR SCREEN IMAGE BUILDING
                CASE DOTSTATE IS
                    WHEN "10" =>
                        PRAMDBO <= (OTHERS => 'Z');
                        PRAMOE_N <= '0';
                        PRAMWE_N <= '1';
                        IF( TEXT_MODE = '1' )THEN
                            IRAMADR <= PRAMADRT12;
                        ELSIF(  (VDPMODEGRAPHIC1 = '1') OR (VDPMODEGRAPHIC2 = '1') OR
                                (VDPMODEGRAPHIC3 = '1') OR (VDPMODEMULTI = '1') OR (VDPMODEMULTIQ = '1') )THEN
                            IRAMADR <= PRAMADRG123M;
                        ELSIF(  (VDPMODEGRAPHIC4 = '1') OR (VDPMODEGRAPHIC5 = '1') OR
                                (VDPMODEGRAPHIC6 = '1') OR (VDPMODEGRAPHIC7 = '1') )THEN
                            IRAMADR <= PRAMADRG4567;
                        END IF;
                    WHEN "01" =>
                        PRAMDBO <= (OTHERS => 'Z' );
                        PRAMOE_N <= '0';
                        PRAMWE_N <= '1';
                        IF( (VDPMODEGRAPHIC6 = '1') OR (VDPMODEGRAPHIC7 = '1') )THEN
                            IRAMADR <= PRAMADRG4567;
                        END IF;
                    WHEN OTHERS =>
                        NULL;
                END CASE;

                IF( (DOTSTATE = "11") AND (VDPVRAMADDRSETREQ /= VDPVRAMADDRSETACK) )THEN
                    VDPVRAMACCESSADDR <= VDPVRAMACCESSADDRTMP;
                    VDPVRAMADDRSETACK <= NOT VDPVRAMADDRSETACK;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -----------------------------------------------------------------------
    -- COLOR DECODING
    -------------------------------------------------------------------------
    U_VDP_COLORDEC: VDP_COLORDEC
    PORT MAP(
        RESET               => RESET                ,
        CLK21M              => CLK21M               ,

        DOTSTATE            => DOTSTATE             ,

        PPALETTEADDR_OUT    => PALETTEADDR_OUT      ,
        PALETTEDATARB_OUT   => PALETTEDATARB_OUT    ,
        PALETTEDATAG_OUT    => PALETTEDATAG_OUT     ,

        VDPMODETEXT1        => VDPMODETEXT1         ,
        VDPMODETEXT1Q       => VDPMODETEXT1Q        ,
        VDPMODETEXT2        => VDPMODETEXT2         ,
        VDPMODEMULTI        => VDPMODEMULTI         ,
        VDPMODEMULTIQ       => VDPMODEMULTIQ        ,
        VDPMODEGRAPHIC1     => VDPMODEGRAPHIC1      ,
        VDPMODEGRAPHIC2     => VDPMODEGRAPHIC2      ,
        VDPMODEGRAPHIC3     => VDPMODEGRAPHIC3      ,
        VDPMODEGRAPHIC4     => VDPMODEGRAPHIC4      ,
        VDPMODEGRAPHIC5     => VDPMODEGRAPHIC5      ,
        VDPMODEGRAPHIC6     => VDPMODEGRAPHIC6      ,
        VDPMODEGRAPHIC7     => VDPMODEGRAPHIC7      ,

        WINDOW              => WINDOW               ,
        SPRITECOLOROUT      => SPRITECOLOROUT       ,
        COLORCODET12        => COLORCODET12         ,
        COLORCODEG123M      => COLORCODEG123M       ,
        COLORCODEG4567      => COLORCODEG4567       ,
        COLORCODESPRITE     => COLORCODESPRITE      ,
        P_YJK_R             => YJK_R                ,
        P_YJK_G             => YJK_G                ,
        P_YJK_B             => YJK_B                ,
        P_YJK_EN            => YJK_EN               ,

        PVIDEOR_VDP         => IVIDEOR_VDP          ,
        PVIDEOG_VDP         => IVIDEOG_VDP          ,
        PVIDEOB_VDP         => IVIDEOB_VDP          ,

        REG_R1_DISP_ON      => REG_R1_DISP_ON       ,
        REG_R7_FRAME_COL    => REG_R7_FRAME_COL     ,
        REG_R8_COL0_ON      => REG_R8_COL0_ON       ,
        REG_R25_YJK         => REG_R25_YJK
    );

    -----------------------------------------------------------------------------
    -- MAKE COLOR CODE
    -----------------------------------------------------------------------------
    U_VDP_TEXT12: VDP_TEXT12
    PORT MAP(
        CLK21M                      => CLK21M,
        RESET                       => RESET,
        DOTSTATE                    => DOTSTATE,
        DOTCOUNTERX                 => PREDOTCOUNTER_X,
        DOTCOUNTERY                 => PREDOTCOUNTER_Y,                         -- Modified by t.hara, 2021/Jul/1st
        DOTCOUNTERYP                => PREDOTCOUNTER_YP,
        VDPMODETEXT1                => VDPMODETEXT1,
        VDPMODETEXT1Q               => VDPMODETEXT1Q,
        VDPMODETEXT2                => VDPMODETEXT2,
        REG_R1_BL_CLKS              => REG_R1_BL_CLKS,
        REG_R7_FRAME_COL            => REG_R7_FRAME_COL,
        REG_R12_BLINK_MODE          => REG_R12_BLINK_MODE,
        REG_R13_BLINK_PERIOD        => REG_R13_BLINK_PERIOD,
        REG_R2_PT_NAM_ADDR          => REG_R2_PT_NAM_ADDR,
        REG_R4_PT_GEN_ADDR          => REG_R4_PT_GEN_ADDR,
        REG_R10R3_COL_ADDR          => REG_R10R3_COL_ADDR,
        PRAMDAT                     => PRAMDAT,
        PRAMADR                     => PRAMADRT12,
        TXVRAMREADEN                => TXVRAMREADEN,
        PCOLORCODE                  => COLORCODET12
    );

    U_VDP_GRAPHIC123M: VDP_GRAPHIC123M
    PORT MAP(
        CLK21M                      => CLK21M,
        RESET                       => RESET,
        DOTSTATE                    => DOTSTATE,
        EIGHTDOTSTATE               => EIGHTDOTSTATE,
        DOTCOUNTERX                 => PREDOTCOUNTER_X,
        DOTCOUNTERY                 => PREDOTCOUNTER_Y,
        VDPMODEMULTI                => VDPMODEMULTI,
        VDPMODEMULTIQ               => VDPMODEMULTIQ,
        VDPMODEGRAPHIC1             => VDPMODEGRAPHIC1,
        VDPMODEGRAPHIC2             => VDPMODEGRAPHIC2,
        VDPMODEGRAPHIC3             => VDPMODEGRAPHIC3,
        REG_R2_PT_NAM_ADDR          => REG_R2_PT_NAM_ADDR,
        REG_R4_PT_GEN_ADDR          => REG_R4_PT_GEN_ADDR,
        REG_R10R3_COL_ADDR          => REG_R10R3_COL_ADDR,
        REG_R26_H_SCROLL            => REG_R26_H_SCROLL,
        REG_R27_H_SCROLL            => REG_R27_H_SCROLL,
        PRAMDAT                     => PRAMDAT,
        PRAMADR                     => PRAMADRG123M,
        PCOLORCODE                  => COLORCODEG123M
    );

    U_VDP_GRAPHIC4567: VDP_GRAPHIC4567
    PORT MAP(
        CLK21M                      => CLK21M,
        RESET                       => RESET,
        DOTSTATE                    => DOTSTATE,
        EIGHTDOTSTATE               => EIGHTDOTSTATE,
        DOTCOUNTERX                 => PREDOTCOUNTER_X,
        DOTCOUNTERY                 => PREDOTCOUNTER_Y,
        VDPMODEGRAPHIC4             => VDPMODEGRAPHIC4,
        VDPMODEGRAPHIC5             => VDPMODEGRAPHIC5,
        VDPMODEGRAPHIC6             => VDPMODEGRAPHIC6,
        VDPMODEGRAPHIC7             => VDPMODEGRAPHIC7,
        REG_R1_BL_CLKS              => REG_R1_BL_CLKS,
        REG_R2_PT_NAM_ADDR          => REG_R2_PT_NAM_ADDR,
        REG_R13_BLINK_PERIOD        => REG_R13_BLINK_PERIOD,
        REG_R26_H_SCROLL            => REG_R26_H_SCROLL,
        REG_R27_H_SCROLL            => REG_R27_H_SCROLL,
        REG_R25_YAE                 => REG_R25_YAE,
        REG_R25_YJK                 => REG_R25_YJK,
        REG_R25_SP2                 => REG_R25_SP2,
        PRAMDAT                     => PRAMDAT,
        PRAMDATPAIR                 => PRAMDATPAIR,
        PRAMADR                     => PRAMADRG4567,
        PCOLORCODE                  => COLORCODEG4567,
        P_YJK_R                     => YJK_R,
        P_YJK_G                     => YJK_G,
        P_YJK_B                     => YJK_B,
        P_YJK_EN                    => YJK_EN
    );

    -----------------------------------------------------------------------------
    -- SPRITE MODULE
    -----------------------------------------------------------------------------
    U_SPRITE: VDP_SPRITE
    PORT MAP(
        CLK21M                      => CLK21M,
        RESET                       => RESET,
        DOTSTATE                    => DOTSTATE,
        EIGHTDOTSTATE               => EIGHTDOTSTATE,
        DOTCOUNTERX                 => PREDOTCOUNTER_X,
        DOTCOUNTERYP                => PREDOTCOUNTER_YP,
        BWINDOW_Y                   => BWINDOW_Y,
        PVDPS0SPCOLLISIONINCIDENCE  => VDPS0SPCOLLISIONINCIDENCE,
        PVDPS0SPOVERMAPPED          => VDPS0SPOVERMAPPED,
        PVDPS0SPOVERMAPPEDNUM       => VDPS0SPOVERMAPPEDNUM,
        PVDPS3S4SPCOLLISIONX        => VDPS3S4SPCOLLISIONX,
        PVDPS5S6SPCOLLISIONY        => VDPS5S6SPCOLLISIONY,
        PVDPS0RESETREQ              => SPVDPS0RESETREQ,
        PVDPS0RESETACK              => SPVDPS0RESETACK,
        PVDPS5RESETREQ              => SPVDPS5RESETREQ,
        PVDPS5RESETACK              => SPVDPS5RESETACK,
        REG_R1_SP_SIZE              => REG_R1_SP_SIZE,
        REG_R1_SP_ZOOM              => REG_R1_SP_ZOOM,
        REG_R11R5_SP_ATR_ADDR       => REG_R11R5_SP_ATR_ADDR,
        REG_R6_SP_GEN_ADDR          => REG_R6_SP_GEN_ADDR,
        REG_R8_COL0_ON              => REG_R8_COL0_ON,
        REG_R8_SP_OFF               => REG_R8_SP_OFF,
        REG_R9_Y_DOTS               => REG_R9_Y_DOTS,
        REG_R23_VSTART_LINE         => REG_R23_VSTART_LINE,
        REG_R27_H_SCROLL            => REG_R27_H_SCROLL,
        SPMODE2                     => SPMODE2,
        SPMAXSPR                    => SPMAXSPR,
        VRAMINTERLEAVEMODE          => VDPMODEISVRAMINTERLEAVE,
        SPVRAMACCESSING             => SPVRAMACCESSING,
        PRAMDAT                     => PRAMDAT,
        PRAMADR                     => PRAMADRSPRITE,
        SPCOLOROUT                  => SPRITECOLOROUT,
        SPCOLORCODE                 => COLORCODESPRITE
    );

    -----------------------------------------------------------------------------
    -- VDP REGISTER ACCESS
    -----------------------------------------------------------------------------
    U_VDP_REGISTER: VDP_REGISTER
    PORT MAP(
        RESET                       => RESET                        ,
        CLK21M                      => CLK21M                       ,

        REQ                         => REQ                          ,
        ACK                         => ACK                          ,
        WRT                         => WRT                          ,
        ADR                         => ADR                          ,
        DBI                         => DBI                          ,
        DBO                         => DBO                          ,

        DOTSTATE                    => DOTSTATE                     ,

        VDPCMDTRCLRACK              => VDPCMDTRCLRACK               ,
        VDPCMDREGWRACK              => VDPCMDREGWRACK               ,
        HSYNC                       => HSYNC                        ,

        VDPS0SPCOLLISIONINCIDENCE   => VDPS0SPCOLLISIONINCIDENCE    ,
        VDPS0SPOVERMAPPED           => VDPS0SPOVERMAPPED            ,
        VDPS0SPOVERMAPPEDNUM        => VDPS0SPOVERMAPPEDNUM         ,
        SPVDPS0RESETREQ             => SPVDPS0RESETREQ              ,
        SPVDPS0RESETACK             => SPVDPS0RESETACK              ,
        SPVDPS5RESETREQ             => SPVDPS5RESETREQ              ,
        SPVDPS5RESETACK             => SPVDPS5RESETACK              ,

        VDPCMDTR                    => VDPCMDTR                     ,
        VD                          => VD                           ,
        HD                          => HD                           ,
        VDPCMDBD                    => VDPCMDBD                     ,
        FIELD                       => FIELD                        ,
        VDPCMDCE                    => VDPCMDCE                     ,
        VDPS3S4SPCOLLISIONX         => VDPS3S4SPCOLLISIONX          ,
        VDPS5S6SPCOLLISIONY         => VDPS5S6SPCOLLISIONY          ,
        VDPCMDCLR                   => VDPCMDCLR                    ,
        VDPCMDSXTMP                 => VDPCMDSXTMP                  ,

        VDPVRAMACCESSDATA           => VDPVRAMACCESSDATA            ,
        VDPVRAMACCESSADDRTMP        => VDPVRAMACCESSADDRTMP         ,
        VDPVRAMADDRSETREQ           => VDPVRAMADDRSETREQ            ,
        VDPVRAMADDRSETACK           => VDPVRAMADDRSETACK            ,
        VDPVRAMWRREQ                => VDPVRAMWRREQ                 ,
        VDPVRAMWRACK                => VDPVRAMWRACK                 ,
        VDPVRAMRDDATA               => VDPVRAMRDDATA                ,
        VDPVRAMRDREQ                => VDPVRAMRDREQ                 ,
        VDPVRAMRDACK                => VDPVRAMRDACK                 ,

        VDPCMDREGNUM                => VDPCMDREGNUM                 ,
        VDPCMDREGDATA               => VDPCMDREGDATA                ,
        VDPCMDREGWRREQ              => VDPCMDREGWRREQ               ,
        VDPCMDTRCLRREQ              => VDPCMDTRCLRREQ               ,

        PALETTEADDR_OUT             => PALETTEADDR_OUT              ,
        PALETTEDATARB_OUT           => PALETTEDATARB_OUT            ,
        PALETTEDATAG_OUT            => PALETTEDATAG_OUT             ,

        CLR_VSYNC_INT               => CLR_VSYNC_INT                ,
        CLR_HSYNC_INT               => CLR_HSYNC_INT                ,
        REQ_VSYNC_INT_N             => REQ_VSYNC_INT_N              ,
        REQ_HSYNC_INT_N             => REQ_HSYNC_INT_N              ,

        REG_R0_HSYNC_INT_EN         => REG_R0_HSYNC_INT_EN          ,
        REG_R1_SP_SIZE              => REG_R1_SP_SIZE               ,
        REG_R1_SP_ZOOM              => REG_R1_SP_ZOOM               ,
        REG_R1_BL_CLKS              => REG_R1_BL_CLKS               ,
        REG_R1_VSYNC_INT_EN         => REG_R1_VSYNC_INT_EN          ,
        REG_R1_DISP_ON              => REG_R1_DISP_ON               ,
        REG_R2_PT_NAM_ADDR          => REG_R2_PT_NAM_ADDR           ,
        REG_R4_PT_GEN_ADDR          => REG_R4_PT_GEN_ADDR           ,
        REG_R10R3_COL_ADDR          => REG_R10R3_COL_ADDR           ,
        REG_R11R5_SP_ATR_ADDR       => REG_R11R5_SP_ATR_ADDR        ,
        REG_R6_SP_GEN_ADDR          => REG_R6_SP_GEN_ADDR           ,
        REG_R7_FRAME_COL            => REG_R7_FRAME_COL             ,
        REG_R8_SP_OFF               => REG_R8_SP_OFF                ,
        REG_R8_COL0_ON              => REG_R8_COL0_ON               ,
        REG_R9_PAL_MODE             => REG_R9_PAL_MODE              ,
        REG_R9_INTERLACE_MODE       => REG_R9_INTERLACE_MODE        ,
        REG_R9_Y_DOTS               => REG_R9_Y_DOTS                ,
        REG_R12_BLINK_MODE          => REG_R12_BLINK_MODE           ,
        REG_R13_BLINK_PERIOD        => REG_R13_BLINK_PERIOD         ,
        REG_R18_ADJ                 => REG_R18_ADJ                  ,
        REG_R19_HSYNC_INT_LINE      => REG_R19_HSYNC_INT_LINE       ,
        REG_R23_VSTART_LINE         => REG_R23_VSTART_LINE          ,
        REG_R25_CMD                 => REG_R25_CMD                  ,
        REG_R25_YAE                 => REG_R25_YAE                  ,
        REG_R25_YJK                 => REG_R25_YJK                  ,
        REG_R25_MSK                 => REG_R25_MSK                  ,
        REG_R25_SP2                 => REG_R25_SP2                  ,
        REG_R26_H_SCROLL            => REG_R26_H_SCROLL             ,
        REG_R27_H_SCROLL            => REG_R27_H_SCROLL             ,

        VDPMODETEXT1                => VDPMODETEXT1                 ,
        VDPMODETEXT1Q               => VDPMODETEXT1Q                ,
        VDPMODETEXT2                => VDPMODETEXT2                 ,
        VDPMODEMULTI                => VDPMODEMULTI                 ,
        VDPMODEMULTIQ               => VDPMODEMULTIQ                ,
        VDPMODEGRAPHIC1             => VDPMODEGRAPHIC1              ,
        VDPMODEGRAPHIC2             => VDPMODEGRAPHIC2              ,
        VDPMODEGRAPHIC3             => VDPMODEGRAPHIC3              ,
        VDPMODEGRAPHIC4             => VDPMODEGRAPHIC4              ,
        VDPMODEGRAPHIC5             => VDPMODEGRAPHIC5              ,
        VDPMODEGRAPHIC6             => VDPMODEGRAPHIC6              ,
        VDPMODEGRAPHIC7             => VDPMODEGRAPHIC7              ,
        VDPMODEISHIGHRES            => VDPMODEISHIGHRES             ,
        SPMODE2                     => SPMODE2                      ,
        VDPMODEISVRAMINTERLEAVE     => VDPMODEISVRAMINTERLEAVE      ,

        FORCED_V_MODE               => FORCED_V_MODE                ,
        SPMAXSPR                    => SPMAXSPR                     ,
        VDP_ID                      => VDP_ID
    );

    -- ★
--  DEBUG_OUTPUT <= REG_R19_HSYNC_INT_LINE & REG_R23_VSTART_LINE;

    -----------------------------------------------------------------------------
    -- VDP COMMAND
    -----------------------------------------------------------------------------
    U_VDP_COMMAND: VDP_COMMAND
    PORT MAP(
        RESET               => RESET                ,
        CLK21M              => CLK21M               ,
        VDPMODEGRAPHIC4     => VDPMODEGRAPHIC4      ,
        VDPMODEGRAPHIC5     => VDPMODEGRAPHIC5      ,
        VDPMODEGRAPHIC6     => VDPMODEGRAPHIC6      ,
        VDPMODEGRAPHIC7     => VDPMODEGRAPHIC7      ,
        VDPMODEISHIGHRES    => VDPMODEISHIGHRES     ,
        VRAMWRACK           => VDPCMDVRAMWRACK      ,
        VRAMRDACK           => VDPCMDVRAMRDACK      ,
        VRAMREADINGR        => VDPCMDVRAMREADINGR   ,
        VRAMREADINGA        => VDPCMDVRAMREADINGA   ,
        VRAMRDDATA          => VDPCMDVRAMRDDATA     ,
        REGWRREQ            => VDPCMDREGWRREQ       ,
        TRCLRREQ            => VDPCMDTRCLRREQ       ,
        REGNUM              => VDPCMDREGNUM         ,
        REGDATA             => VDPCMDREGDATA        ,
        PREGWRACK           => VDPCMDREGWRACK       ,
        PTRCLRACK           => VDPCMDTRCLRACK       ,
        PVRAMWRREQ          => VDPCMDVRAMWRREQ      ,
        PVRAMRDREQ          => VDPCMDVRAMRDREQ      ,
        PVRAMACCESSADDR     => VDPCMDVRAMACCESSADDR ,
        PVRAMWRDATA         => VDPCMDVRAMWRDATA     ,
        PCLR                => VDPCMDCLR            ,
        PCE                 => VDPCMDCE             ,
        PBD                 => VDPCMDBD             ,
        PTR                 => VDPCMDTR             ,
        PSXTMP              => VDPCMDSXTMP          ,
        CUR_VDP_COMMAND     => CUR_VDP_COMMAND      ,
        REG_R25_CMD         => REG_R25_CMD
    );

    U_VDP_WAIT_CONTROL: VDP_WAIT_CONTROL
    PORT MAP (
        RESET               => RESET                ,
        CLK21M              => CLK21M               ,

        VDP_COMMAND         => CUR_VDP_COMMAND      ,

        VDPR9PALMODE        => VDPR9PALMODE         ,
        REG_R1_DISP_ON      => REG_R1_DISP_ON       ,
        REG_R8_SP_OFF       => REG_R8_SP_OFF        ,
        REG_R9_Y_DOTS       => REG_R9_Y_DOTS        ,

        VDPSPEEDMODE        => VDPSPEEDMODE         ,
        DRIVE               => VDP_COMMAND_DRIVE    ,

        ACTIVE              => VDP_COMMAND_ACTIVE
    );

END RTL;

