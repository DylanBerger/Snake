module snake (
	 input  logic 			 enable,
    input  logic         clk,             // System clock
    input  logic         rst,             // Reset signal
    input  logic [1:0]   direction,       // User input controls
    input  logic         apple_eaten,     // Flag from apple module
    input  logic [3:0]   apple_x,         // Apple position X (from apples module)
    input  logic [3:0]   apple_y,         // Apple position Y (from apples module)
    output logic [3:0]   head_x,          // Snake head position X
    output logic [3:0]   head_y,          // Snake head position Y
    output logic [15:0][15:0] RedPixels,  // LED matrix output for snake body & apple
    output logic [15:0][15:0] GrnPixels,  // LED matrix output for snake head
    output logic [7:0]   snake_length,    // Snake length output
    input  logic         collision,
    output logic [3:0] x[0:127], 
    output logic [3:0] y[0:127]
);

    // Snake body coordinate arrays (max length 128)
    logic [3:0] tail_x, tail_y;
    
    // Compute new head position BEFORE updating arrays
	logic [3:0] new_x, new_y;

	always_ff @(posedge clk or posedge rst) begin
		 if (rst) begin
			  x[0] <= 4'd8;  y[0] <= 4'd8;  // Head
			  x[1] <= 4'd7;  y[1] <= 4'd8;  // Middle segment
			  x[2] <= 4'd6;  y[2] <= 4'd8;  // Tail
			  snake_length <= 3;
			  head_x <= 4'd8;  
			  head_y <= 4'd8;
			  RedPixels <= '{default:1'b0};
			  GrnPixels <= '{default:1'b0};
		 end else if (collision) begin
			  RedPixels <= '{default:1'b0};
			  GrnPixels <= '{default:1'b0};
		 end else begin
			  // Compute new head position before updates
			  new_x = x[0];
			  new_y = y[0];
			  case (direction)
					2'b00: new_x = x[0] - 1; // Left
					2'b01: new_x = x[0] + 1; // Right
					2'b10: new_y = y[0] - 1; // Up
					2'b11: new_y = y[0] + 1; // Down
			  endcase

			  // Shift snake body
			  for (int i = 127; i > 0; i--) begin
					if (i < snake_length) begin
						 x[i] <= x[i-1];
						 y[i] <= y[i-1];
					end
			  end

			  // Assign new head position AFTER shifting body
			  x[0] <= new_x;
			  y[0] <= new_y;
			  head_x <= new_x;
			  head_y <= new_y;

			  // Increase snake length if apple was eaten
			  if (apple_eaten) begin
					snake_length <= snake_length + 1;
			  end

			  // Update LED matrix
			  RedPixels <= '{default:1'b0};
			  GrnPixels <= '{default:1'b0};

			  for (int j = 1; j < 128; j++) begin
               if (j < snake_length) begin
                   RedPixels[x[j]][y[j]] <= 1;
               end
           end

			  GrnPixels[head_x][head_y] <= 1;
			  RedPixels[apple_x][apple_y] <= 1;
		 end
	end 
endmodule


module snake_testbench();//change to snake_testbench()
	logic clk, rst;
   logic [15:0][15:0] RedPixels, GrnPixels;
   logic [1:0] direction; 
	logic apple_eaten;
   logic [3:0] head_x;   // Snake head position X
   logic [3:0] head_y;
	logic collision;
	logic [7:0] snake_length;
	logic [3:0]   apple_x;         // Apple position X (from apples module)
   logic [3:0]   apple_y;         // Apple position Y (from apples module)
	
	snake dut (.clk, .rst, .direction, .apple_eaten, .apple_x, .apple_y, .head_x, .head_y, .RedPixels, .GrnPixels, .snake_length, .collision);
	
	//Set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) 
		clk <= ~clk;
	end

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
		collision <= 0; direction = 2'b10; 	@(posedge clk); //move up
														@(posedge clk);
														@(posedge clk);
		apple_eaten <= 1; repeat(4)			@(posedge clk);
		apple_eaten <= 0;							@(posedge clk);												
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		direction <= 2'b00;						@(posedge clk); //left
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		repeat(20)									@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														
														
		$stop; 
	end 
endmodule  
