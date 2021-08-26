
module hdmi_config
(
   // Host Side
   input       iCLK,
   input       iRST_N,

   input       dvi_mode,
   input       audio_96k,

   // I2C Side
   output      I2C_SCL,
   inout       I2C_SDA
);

// Internal Registers/Wires
reg        mI2C_GO = 0;
wire       mI2C_END;
wire       mI2C_ACK;
reg [15:0] LUT_DATA;
reg  [7:0] LUT_INDEX = 0;

i2c #(27_000_000, 20_000) i2c_av
(
   .CLK(iCLK),

   .I2C_SCL(I2C_SCL),      // I2C CLOCK
   .I2C_SDA(I2C_SDA),      // I2C DATA

   .I2C_DATA({8'h98,init_data[LUT_INDEX]}),  // DATA:[SLAVE_ADDR,SUB_ADDR,DATA]. 0x98 is the Slave Address of the IT66121 chip!
   .START(mI2C_GO),        // START transfer
   .END(mI2C_END),         // END transfer
   .ACK(mI2C_ACK)          // ACK
);

//////////////////////  Config Control ////////////////////////////
always@(posedge iCLK or negedge iRST_N)
begin
   reg  [1:0] mSetup_ST = 0;

   if(!iRST_N)
      begin
         LUT_INDEX   <= 0;
         mSetup_ST   <= 0;
         mI2C_GO     <= 0;
      end
   else
      begin
         if(init_data[LUT_INDEX] != 16'hFFFF)
            begin

               case(mSetup_ST)

                  0: begin
                        mI2C_GO     <= 1;
                        mSetup_ST   <= 1;
                     end

                  1: if(~mI2C_END) mSetup_ST <= 2;

                  2: begin

                        mI2C_GO <= 0;

                        if(mI2C_END)
                           begin
                              mSetup_ST <= 0;
                              if(!mI2C_ACK) LUT_INDEX <= LUT_INDEX + 8'd1;
                           end

                     end
               endcase

            end
      end
end

////////////////////////////////////////////////////////////////////
/////////////////////   Config Data LUT   //////////////////////////

wire [15:0] init_data[38] =
'{


// ATTENTION!!! This is a VERY basic IT66121 init.
// - No INTs are handled
// - Default audio init
// - Signals "as is", no convertion of any kind


   //---------------
   // INIT
// {8'h0F, 8'b0000_1000},  // Enable GRCLK (for i2c)   default 0000_1000


// {8'h62, 8'b1000_0000},  // XP_RESETB  default 1000_1000

// {8'h64, 8'b1001_0000},  // IP_RESETB  default 1001_0100

//    16'h01,0x00,0x00,    // idle(100);

// {8'h04, 8'b0011_1100},  // RESET HDMI  default b0001_1100
// {8'h04, 8'b0011_1101},  // Set to wait for function enable

//    16'h01,0x00,0x00,    // idle(100);

   {8'h0F, 8'b0000_1000},  // bank 0 ;

   //low clock
   {8'h62, 8'b0001_1000},  // TMDS clk <80MHz 1000 1000
   {8'h64, 8'b0001_1101},  // PCLKIN <80MHz 1001 0100
   {8'h68, 8'b0001_0000},  // TMDS clk <80MHz 0000 0000
   //---------------

   //---------------
   // DefaultVideo_Table
   {8'h72, 8'b0000_0000},  // no color conversion 0000 0000
   {8'h70, 8'b0000_0000},  // RGB mode 0000 0000
   {8'h04, 8'b0001_0100},  // clear the RESET flag 0001 1100
   //---------------


   //pattern init can be here, but it's not needed


   ////////////////////////////////////////////////////
   // Config default audio output format
   ////////////////////////////////////////////////////

   {8'hE0,  8'h01},        // 16 bits - I2S source 0
   {8'hE1,  8'h40},        // 01 = 32 bit I2s? 00=standard I2S --full packet?
   {8'hE2,  8'hE4},        // standard FIFO
   {8'hE3,  8'h00},        // default
   {8'hE4,  8'h00},        // default
   {8'hE5,  8'h00},        // default

   // {8'hC5,  8'h00},     // CTS auto count
   // {8'hCE,  8'h03},     // Audio InfoFrame packet


   {8'h0F, 8'b0000_1001},  // bank 1 ;

   {8'h33, 8'h00},         // N = 6144
   {8'h34, 8'h18},
   {8'h35, 8'h00},

   {8'h91, 8'h01},         // 2 audio channels without pre-emphasis, Linear PCM format audio --mono?
   {8'h92, 8'h00},
   {8'h93, 8'h01},
   {8'h94, 8'h00},

   {8'h98, 8'h02},         // 02 = 48khz          00 = 44khz
   {8'h99, 8'hD2},         // DB = 48khz/24 bits  F2 = 44khz/16 bits  D2 = 48khz/16 bits

   {8'h0F, 8'b0000_1000},  // bank 0 ;

   {8'h04, 8'h00},


   //---------------
   // SetHDMI_Table
   {8'hC0, 7'b0000_000,~dvi_mode},  // HDMI mode 0000 0000
   {8'hC1, 8'b0000_0000},  // avmute (not muted) 0000 0001
   {8'hC6, 8'b0000_0011},  // Enable General Control packet, one for each field 0000 0000
   //---------------

   //---------------
   // PwrOn_Table
   {8'h0F, 8'b0011_1000},  // PwrOn RCLK (for i2c)
   {8'h05, 8'b0110_0000},  // PwrOn PCLK

   // PLL PwrOn
   {8'h61, 8'b0001_0000},  // PwrOn DRV  0001 0000
   {8'h62, 8'b0001_1000},  // PwrOn XPLL
   {8'h64, 8'b0001_1101},  // PwrOn IPLL

   // PLL Reset OFF
   {8'h61, 8'b0000_0000},  // DRV_RST
   {8'h62, 8'b0001_1000},  // XP_RESETB
   {8'h64, 8'b0001_1101},  // IP_RESETB

   {8'h0F, 8'b0001_1000},  // PwrOn IACLK
   //---------------


   16'hFFFF                // END

};

////////////////////////////////////////////////////////////////////

endmodule
