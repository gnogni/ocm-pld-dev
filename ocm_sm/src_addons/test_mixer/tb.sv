module tb;
	localparam		CLK_BASE	= 1000000000/(21477270 * 4);

	reg				memclk;
	reg		[1:0]	ff_clk21 = 2'd0;
	reg				pClk21m;
	wire			reset;
	wire			power_on_reset;
	wire	[5:0]	pDac_SL;
	wire	[5:0]	pDac_SR;

	// -------------------------------------------------------------
	//	clock generator
	// -------------------------------------------------------------
	always #(CLK_BASE/2) begin
		memclk	<= ~memclk;
	end

	always @( posedge memclk ) begin
		ff_clk21 <= ff_clk21 + 2'd1;
		if( ff_clk21 == 2'd0 ) begin
			pClk21m <= ~pClk21m;
		end
	end

	// -------------------------------------------------------------
	//	DUT
	// -------------------------------------------------------------
	emsx_top u_emsx_top (
		.memclk				( memclk				),
		.pClk21m			( pClk21m				),
		.reset				( reset					),
		.power_on_reset		( power_on_reset		),
		.pDac_SL			( pDac_SL				),
		.pDac_SR			( pDac_SR				)
	);


	// -------------------------------------------------------------
	//	sequence
	// -------------------------------------------------------------
	initial begin
//		reset			= 'bZ;
//		power_on_reset	= 'b0;
		memclk			= 'b0;
		pClk21m			= 'b0;

		repeat ( 10 ) @( posedge pClk21m );

//		reset			= 1'bZ;

		repeat( 100000000 ) @( posedge pClk21m );

		$finish;
	end
endmodule
