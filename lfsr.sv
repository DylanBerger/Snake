module LFSR(clk, rst, Q);
	output logic [15:0] Q;
	input logic clk, rst; 
	
	logic xnor_out;
	
	assign xnor_out = (Q[0] ~^ Q[1] ~^ Q[3] ~^ Q[12]); 
	
	always_ff @(posedge clk) begin
		if(rst) Q <= 16'b1010101010101010;
		
		else Q <= {xnor_out, Q[15: 1]};
	end
	
endmodule

module LFSR_testbench();
	logic clk, rst;
   logic [15:0] Q;         
	
	LFSR dut (.clk, .rst, .Q);
	
	//Set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) 
		clk <= ~clk;
	end
	
	//Set up the inputs to the design. Each line is a clock cycle
	initial begin
														@(posedge clk);
		rst <= 1;									@(posedge clk);
														@(posedge clk);
		rst <= 0;									@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);//see if the default state is correct at MR
														@(posedge clk);
														@(posedge clk); //move up
														@(posedge clk);
		repeat(20)									@(posedge clk);
														@(posedge clk);												
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk); 
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														
														
		$stop; 
	end 
endmodule  