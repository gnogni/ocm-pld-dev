module tb;
	localparam		clk_base	= 1000000000/21477/2;

	reg				clk21m;
	reg				reset;
	reg				count_en;
	reg				af_increment;
	reg				af_decriment;
	wire			af_mask;
	wire	[3:0]	af_speed;

	// -------------------------------------------------------------
	//	clock generator
	// -------------------------------------------------------------
	always #( clk_base ) begin
		clk21m	<= ~clk21m;
	end

	// -------------------------------------------------------------
	//	dut
	// -------------------------------------------------------------
	autofire u_autofire (
		.clk21m			( clk21m		),
		.reset			( reset			),
		.count_en		( count_en		),
		.af_increment	( af_increment	),
		.af_decriment	( af_decriment	),
		.af_mask		( af_mask		),
		.af_speed		( af_speed		)
	);

	initial begin
		clk21m			= 0;
		reset			= 1;
		count_en		= 0;
		af_increment	= 0;
		af_decriment	= 0;

		// --------------------------------------------------------------------
		//	Initial state
		repeat( 10 ) @( posedge clk21m );
		reset		<= 0;
		@( negedge clk21m );

		repeat( 10 ) @( posedge clk21m );

		repeat( 100 ) begin
			count_en	<= 1;
			repeat( 4 ) @( posedge clk21m );
			count_en	<= 0;
			repeat( 4 ) @( posedge clk21m );
		end

		repeat( 18 ) begin
			count_en	<= 1;
			@( posedge clk21m );
			af_decriment	<= 1;
			@( posedge clk21m );
			af_decriment	<= 0;
			@( posedge clk21m );
			@( posedge clk21m );
			count_en	<= 0;
			repeat( 4 ) @( posedge clk21m );

			repeat( 100 ) begin
				count_en	<= 1;
				repeat( 4 ) @( posedge clk21m );
				count_en	<= 0;
				repeat( 4 ) @( posedge clk21m );
			end
		end

		repeat( 18 ) begin
			count_en	<= 1;
			@( posedge clk21m );
			af_increment	<= 1;
			@( posedge clk21m );
			af_increment	<= 0;
			@( posedge clk21m );
			@( posedge clk21m );
			count_en	<= 0;
			repeat( 4 ) @( posedge clk21m );

			repeat( 100 ) begin
				count_en	<= 1;
				repeat( 4 ) @( posedge clk21m );
				count_en	<= 0;
				repeat( 4 ) @( posedge clk21m );
			end
		end

		$finish;
	end
endmodule
