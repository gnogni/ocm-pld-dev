module tb;
	localparam		CLK_BASE	= 1000000000/21477270;

	reg				clk21m;
	reg				reset;
	wire			clkena;
	reg				req;
	wire			ack;
	reg				wrt;
	reg		[15:0]	adr;
	wire	[7:0]	dbi;
	reg		[7:0]	dbo;

	reg		[5:0]	joya_in;
	wire	[1:0]	joya_out;
	wire			stra;
	reg		[5:0]	joyb_in;
	wire	[1:0]	joyb_out;
	wire			strb;

	wire			kana;
	reg				ecmtin;
	reg				ekeymode;

	wire	[7:0]	wave;

	reg		[2:0]	ff_clk_div;

	// -------------------------------------------------------------
	//	clock generator
	// -------------------------------------------------------------
	always #(CLK_BASE/2) begin
		clk21m	<= ~clk21m;
	end

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_clk_div <= 3'b0;
		end
		else if( ff_clk_div == 3'd5 ) begin
			ff_clk_div <= 3'b0;
		end
		else begin
			ff_clk_div	<= ff_clk_div + 3'd1;
		end
	end

	assign clkena	= (ff_clk_div == 3'd5) ? 1'b1 : 1'b0;

	// -------------------------------------------------------------
	//	DUT
	// -------------------------------------------------------------
	psg u_psg (
		.clk21m		( clk21m		),
		.reset		( reset			),
		.clkena		( clkena		),
		.req		( req			),
		.ack		( ack			),
		.wrt		( wrt			),
		.adr		( adr			),
		.dbi		( dbi			),
		.dbo		( dbo			),
		.joya_in	( joya_in		),
		.joya_out	( joya_out		),
		.stra		( stra			),
		.joyb_in	( joyb_in		),
		.joyb_out	( joyb_out		),
		.strb		( strb			),
		.kana		( kana			),
		.cmtin		( cmtin			),
		.keymode	( keymode		),
		.wave		( wave			)
	);


	// -------------------------------------------------------------
	//	sequence
	// -------------------------------------------------------------
	initial begin
		reset			= 'b1;
		clk21m			= 'b0;
		req				= 'b0;
		wrt				= 'b0;
		adr				= 'd0;
		dbo				= 'd0;
		joya_in			= 'd0;
		joyb_in			= 'd0;
		ecmtin			= 'd0;
		ekeymode		= 'd0;

		repeat ( 10 ) @( posedge clk21m );

		reset			= 1'b0;

		repeat( 30000000 ) @( posedge clk21m );

		$finish;
	end
endmodule
