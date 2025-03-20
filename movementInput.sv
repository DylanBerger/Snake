module movementInput(clk, rst, L, R, U, D, direction);
    input logic clk, rst;
    input logic L, R, U, D;
    output logic [1:0] direction;
    
    enum logic [1:0] {ML = 2'b00, MR = 2'b01, MU = 2'b10, MD = 2'b11} ps, ns;

    always_comb begin 
        ns = ps;
        case(ps)
            ML: if (U) ns = MU; else if (D) ns = MD;
            MR: if (U) ns = MU; else if (D) ns = MD;
            MU: if (L) ns = ML; else if (R) ns = MR;
            MD: if (L) ns = ML; else if (R) ns = MR;
            default: ns = ps;
        endcase
    end
    
    
    always_comb direction = ps;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            ps <= MR; 
        else
            ps <= ns;
    end
endmodule

module movementInput_testbench();
	logic clk, rst;
   logic L, R, U, D;
   logic [1:0] direction; 
	
	movementInput dut (.clk, .rst, .L, .R, .U, .D, .direction);
	
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
		L <= 0; R <= 1; 							@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		L <= 1; R <= 0; 							@(posedge clk); //check that despite MR, it doesn't change with a parallel input
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		L <= 0; R <= 0; U <= 1; D <= 0;	   @(posedge clk); //should change to MU
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		L <= 1; R <= 0; U <= 0; D <= 0;	   @(posedge clk); //should change to ML
														@(posedge clk);
														@(posedge clk);
		rst <= 1;									@(posedge clk); //test reset again to see if it defaults to MR
														@(posedge clk);
		rst <= 0;									@(posedge clk);
														@(posedge clk);
														@(posedge clk);												
		L <= 0; R <= 0; U <= 0; D <= 1;	   @(posedge clk); //MD
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		L <= 0; R <= 0; U <= 1; D <= 0;	   @(posedge clk); //MD
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		L <= 1; R <= 1; U <= 0; D <= 0;	   @(posedge clk); //Just curious and want to see if it's a problem
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														
		$stop; 
	end 
endmodule 
