--
-- vdp_wait_control.vhd
--   VDP wait controller for VDP command
--   Revision 2.00
--
-- Copyright (c) 2008 Takayuki Hara
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
-- Revision History
--
-- 27th,Apr,2025 modified by KdL
--  - Converted from a constant array to block RAM for resource optimization
--
-- 2nd,Jun,2021 modified by KdL
--  - LMMV is reverted to previous speed in accordance with current VDP module
--
-- 9th,Jan,2020 modified by KdL
--  - LMMV fix which improves the Sunrise logo a bit (temporary solution?)
--    Some glitches appear to be unrelated to the VDP_COMMAND entity and
--    the correct speed is not yet reached
--
-- 20th,May,2019 modified by KdL
--  - Optimization of speed parameters for greater game compatibility
--
-- 14th,May,2018 modified by KdL
--  - Improved the speed accuracy of SRCH, LINE, LMMV, LMMM, HMMV, HMMM and YMMM
--  - Guidelines at https://map.grauw.nl/articles/vdp_commands_speed.php
--
--  - Some evaluation tests:
--    - overall duration of the SPACE MANBOW game intro at 3.58MHz
--    - uncorrupted music in the FRAY game intro at 3.58MHz, 5.37MHz and 8.06MHz
--    - amount of artifacts in the BREAKER game at 5.37MHz
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VDP_WAIT_CONTROL IS
    PORT(
        RESET           : IN    STD_LOGIC;
        CLK21M          : IN    STD_LOGIC;

        VDP_COMMAND     : IN    STD_LOGIC_VECTOR(  7 DOWNTO  4 );

        VDPR9PALMODE    : IN    STD_LOGIC;      -- 0=60Hz (NTSC), 1=50Hz (PAL)
        REG_R1_DISP_ON  : IN    STD_LOGIC;      -- 0=Display Off, 1=Display On
        REG_R8_SP_OFF   : IN    STD_LOGIC;      -- 0=Sprite On, 1=Sprite Off
        REG_R9_Y_DOTS   : IN    STD_LOGIC;      -- 0=192 Lines, 1=212 Lines

        VDPSPEEDMODE    : IN    STD_LOGIC;
        DRIVE           : IN    STD_LOGIC;

        ACTIVE          : OUT   STD_LOGIC
    );
END VDP_WAIT_CONTROL;

ARCHITECTURE RTL OF VDP_WAIT_CONTROL IS

    SIGNAL FF_WAIT_CNT  : STD_LOGIC_VECTOR( 15 DOWNTO  0 );

    TYPE WAIT_ROM_ARRAY_T IS ARRAY( 0 TO 255 ) OF STD_LOGIC_VECTOR( 15 DOWNTO  0 );
    SIGNAL WAIT_ROM : WAIT_ROM_ARRAY_T := (
        ---------------------------------------------------------------
        --      "STOP",         "XXXX",         "XXXX",         "XXXX",
        --      "POINT",        "PSET",         "SRCH",         "LINE",
        --      "LMMV",         "LMMM",         "LMCM",         "LMMC",
        --      "HMMV",         "HMMM",         "YMMM",         "HMMC",
        ---------------------------------------------------------------
        -- C_WAIT_TABLE_501 : Sprite On, 212 Lines, 50Hz
        0   => X"8000", 1   => X"8000", 2   => X"8000", 3   => X"8000",
        4   => X"8000", 5   => X"8000", 6   => X"19E5", 7   => X"0F31",
        8   => X"10F9", 9   => X"1289", 10  => X"8000", 11  => X"8000",
        12  => X"119D", 13  => X"1965", 14  => X"1591", 15  => X"8000",

        -- C_WAIT_TABLE_502 : Sprite On, 192 Lines, 50Hz
        16  => X"8000", 17  => X"8000", 18  => X"8000", 19  => X"8000",
        20  => X"8000", 21  => X"8000", 22  => X"18C9", 23  => X"0E81",
        24  => X"1019", 25  => X"11B5", 26  => X"8000", 27  => X"8000",
        28  => X"10B1", 29  => X"1849", 30  => X"1515", 31  => X"8000",

        -- C_WAIT_TABLE_503 : Sprite Off, 212 Lines, 50Hz
        32  => X"8000", 33  => X"8000", 34  => X"8000", 35  => X"8000",
        36  => X"8000", 37  => X"8000", 38  => X"1679", 39  => X"0A11",
        40  => X"0CE5", 41  => X"10AD", 42  => X"8000", 43  => X"8000",
        44  => X"0CA9", 45  => X"15F9", 46  => X"1521", 47  => X"8000",

        -- C_WAIT_TABLE_504 : Sprite Off, 192 Lines, 50Hz
        48  => X"8000", 49  => X"8000", 50  => X"8000", 51  => X"8000",
        52  => X"8000", 53  => X"8000", 54  => X"15B9", 55  => X"0A01",
        56  => X"0C79", 57  => X"0FFD", 58  => X"8000", 59  => X"8000",
        60  => X"0C5D", 61  => X"1539", 62  => X"144D", 63  => X"8000",

        -- C_WAIT_TABLE_505 : Blank, 50Hz (Test: Sprite On, 212 Lines)
        64  => X"8000", 65  => X"8000", 66  => X"8000", 67  => X"8000",
        68  => X"8000", 69  => X"8000", 70  => X"13C5", 71  => X"08D5",
        72  => X"0CC5", 73  => X"0E69", 74  => X"8000", 75  => X"8000",
        76  => X"0CAD", 77  => X"1385", 78  => X"12DD", 79  => X"8000",

        ---------------------------------------------------------------
        --      "STOP",         "XXXX",         "XXXX",         "XXXX",
        --      "POINT",        "PSET",         "SRCH",         "LINE",
        --      "LMMV",         "LMMM",         "LMCM",         "LMMC",
        --      "HMMV",         "HMMM",         "YMMM",         "HMMC",
        ---------------------------------------------------------------
        -- C_WAIT_TABLE_601 : Sprite On, 212 Lines, 60Hz
        80  => X"8000", 81  => X"8000", 82  => X"8000", 83  => X"8000",
        84  => X"8000", 85  => X"8000", 86  => X"1AC5", 87  => X"10F1",
        88  => X"13DD", 89  => X"15B5", 90  => X"8000", 91  => X"8000",
        92  => X"14CD", 93  => X"1A45", 94  => X"182D", 95  => X"8000",

        -- C_WAIT_TABLE_602 : Sprite On, 192 Lines, 60Hz
        96  => X"8000", 97  => X"8000", 98  => X"8000", 99  => X"8000",
        100 => X"8000", 101 => X"8000", 102 => X"18E5", 103 => X"0FC1",
        104 => X"1275", 105 => X"1425", 106 => X"8000", 107 => X"8000",
        108 => X"1319", 109 => X"1865", 110 => X"16FD", 111 => X"8000",

        -- C_WAIT_TABLE_603 : Sprite Off, 212 Lines, 60Hz
        112 => X"8000", 113 => X"8000", 114 => X"8000", 115 => X"8000",
        116 => X"8000", 117 => X"8000", 118 => X"1675", 119 => X"0AB1",
        120 => X"0E25", 121 => X"12B5", 122 => X"8000", 123 => X"8000",
        124 => X"0DFD", 125 => X"15F5", 126 => X"17B5", 127 => X"8000",

        -- C_WAIT_TABLE_604 : Sprite Off, 192 Lines, 60Hz
        128 => X"8000", 129 => X"8000", 130 => X"8000", 131 => X"8000",
        132 => X"8000", 133 => X"8000", 134 => X"1565", 135 => X"0A41",
        136 => X"0D7D", 137 => X"11AD", 138 => X"8000", 139 => X"8000",
        140 => X"0D59", 141 => X"14E5", 142 => X"167D", 143 => X"8000",

        -- C_WAIT_TABLE_605 : Blank, 60Hz (Test: Sprite On, 212 Lines)
        144 => X"8000", 145 => X"8000", 146 => X"8000", 147 => X"8000",
        148 => X"8000", 149 => X"8000", 150 => X"1279", 151 => X"08F1",
        152 => X"0D59", 153 => X"0EFD", 154 => X"8000", 155 => X"8000",
        156 => X"0D39", 157 => X"11F9", 158 => X"13D5", 159 => X"8000",

        -- Reserved / Unused (Set to zero)
        OTHERS => X"0000"
    );

    SIGNAL TABLE_IDX         : INTEGER  RANGE 0 TO 9;
    SIGNAL COMBINED_ADDR     : INTEGER  RANGE 0 TO 255;
    SIGNAL COMBINED_ADDR_REG : INTEGER  RANGE 0 TO 255;
    SIGNAL WAIT_ROM_Q        : STD_LOGIC_VECTOR( 15 DOWNTO  0 );

BEGIN

    PROCESS( RESET, CLK21M )
    BEGIN
        IF( RESET = '1' )THEN
            FF_WAIT_CNT         <= (OTHERS => '0');
            COMBINED_ADDR_REG   <= 0;
        ELSIF( CLK21M'EVENT AND CLK21M = '1' )THEN
            IF( DRIVE = '1' )THEN
                -- 50Hz (PAL)
                IF( VDPR9PALMODE = '1' )THEN
                    -- Display On
                    IF( REG_R1_DISP_ON = '1' )THEN
                        -- Sprite On
                        IF( REG_R8_SP_OFF = '0' )THEN
                            -- 212 Lines
                            IF( REG_R9_Y_DOTS = '1' )THEN
                                TABLE_IDX   <= 0;           -- C_WAIT_TABLE_501
                            -- 192 Lines
                            ELSE
                                TABLE_IDX   <= 1;           -- C_WAIT_TABLE_502
                            END IF;
                        -- Sprite Off
                        ELSE
                            -- 212 Lines
                            IF( REG_R9_Y_DOTS = '1' )THEN
                                TABLE_IDX   <= 2;           -- C_WAIT_TABLE_503
                            -- 192 Lines
                            ELSE
                                TABLE_IDX   <= 3;           -- C_WAIT_TABLE_504
                            END IF;
                        END IF;
                    -- Display Off (Blank)
                    ELSE
                        TABLE_IDX   <= 4;                   -- C_WAIT_TABLE_505
                    END IF;
                -- 60Hz (NTSC)
                ELSE
                    -- Display On
                    IF( REG_R1_DISP_ON = '1' )THEN
                        -- Sprite On
                        IF( REG_R8_SP_OFF = '0' )THEN
                            -- 212 Lines
                            IF( REG_R9_Y_DOTS = '1' )THEN
                                TABLE_IDX   <= 5;           -- C_WAIT_TABLE_601
                            -- 192 Lines
                            ELSE
                                TABLE_IDX   <= 6;           -- C_WAIT_TABLE_602
                            END IF;
                        -- Sprite Off
                        ELSE
                            -- 212 Lines
                            IF( REG_R9_Y_DOTS = '1' )THEN
                                TABLE_IDX   <= 7;           -- C_WAIT_TABLE_603
                            -- 192 Lines
                            ELSE
                                TABLE_IDX   <= 8;           -- C_WAIT_TABLE_604
                            END IF;
                        END IF;
                    -- Display Off (Blank)
                    ELSE
                        TABLE_IDX   <= 9;                   -- C_WAIT_TABLE_605
                    END IF;
                END IF;
                COMBINED_ADDR       <= TABLE_IDX * 16 + TO_INTEGER(UNSIGNED(VDP_COMMAND));
                -- Pipeline stage: separation for ROM read
                COMBINED_ADDR_REG   <= COMBINED_ADDR;
                FF_WAIT_CNT         <= ('0' & FF_WAIT_CNT( 14 DOWNTO  0 )) + WAIT_ROM_Q;
            END IF;
        END IF;
    END PROCESS;

    PROCESS( CLK21M )
    BEGIN
        IF( CLK21M'EVENT AND CLK21M = '1' )THEN
            WAIT_ROM_Q <= WAIT_ROM(COMBINED_ADDR_REG);
        END IF;
    END PROCESS;

    ACTIVE <= FF_WAIT_CNT(15) OR VDPSPEEDMODE;
END RTL;
