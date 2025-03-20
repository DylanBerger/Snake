module apples (
	 input logic enable,
    input logic clk,
    input logic rst,
    input logic [15:0] Q,         
    input logic [3:0] head_x,     
    input logic [3:0] head_y,     
    input logic collision,
    output logic apple_eaten,     
    output logic [3:0] apple_x,   
    output logic [3:0] apple_y    
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            apple_x <= Q[3:0];
            apple_y <= Q[7:4];
            apple_eaten <= 0;  
        end else if ((head_x == apple_x) && (head_y == apple_y)) begin
            apple_eaten <= 1;  // Mark apple as eaten
            apple_x <= Q[3:0];  
            apple_y <= Q[7:4];  
        end else begin
            apple_eaten <= 0;  // Reset apple_eaten when apple is not being eaten
        end
    end
	  
endmodule


module apples_testbench();
	logic clk, rst;
   logic [15:0] Q;         
   logic [3:0] head_x;     
   logic [3:0] head_y;     
	logic [15:0][15:0] RedPixels;
   logic apple_eaten; 
	logic collision;
   logic [3:0] apple_x;   
   logic [3:0] apple_y;
	logic [3:0] prev_apple_x;
   logic [3:0] prev_apple_y;
	
	apples dut (.clk, .rst, .Q, .head_x, .head_y, .collision, .apple_eaten, .apple_x, .apple_y);
	
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
		apple_eaten <= 1; 						@(posedge clk); //move up
														@(posedge clk);
														@(posedge clk);
		apple_eaten <= 1; 						@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		apple_eaten <= 1; 						@(posedge clk);
		repeat(20)									@(posedge clk);
														@(posedge clk);												
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		collision <= 1; apple_eaten <= 0;	@(posedge clk); 
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														
														
		$stop; 
	end 
endmodule  

