module collision (
    input logic clk,             // System clock
    input logic rst,             // Reset signal
    input logic [3:0] head_x, head_y, // Head position
    input logic [3:0] x[0:127], y[0:127], // Snake body positions (matching snake module)
    input logic [7:0] snake_length, // Snake length
    output logic collision // Collision detected (self-collision or border)
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            collision <= 0;
        end else begin
            collision <= 0;
				
            if (head_x > 15 || head_y > 15) begin //scrapped
                collision <= 1; 
            end else begin
                
                for (int i = 1; i < 128; i++) begin
                    if ((i < snake_length) && (head_x == x[i]) && (head_y == y[i])) begin
                        collision <= 1; // Self-collision detected
                    end
                end
            end
        end
    end
endmodule

module collision_testbench();
	 logic clk;             // System clock
    logic rst;             // Reset signal
    logic [3:0] head_x, head_y; // Head position
    logic [3:0] x[0:127], y[0:127]; // Snake body positions (matching snake module)
    logic [7:0] snake_length; // Snake length
    logic collision; // Collision detected (self-collision or border)

	collision dut (
        .clk(clk),
        .rst(rst),
        .head_x(head_x),
        .head_y(head_y),
        .x(x),
        .y(y),
        .snake_length(snake_length),
        .collision(collision)
    );

	parameter CLOCK_PERIOD = 100;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD / 2) 
			clk <= ~clk;
		end
		
		initial begin
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        repeat (2) @(posedge clk);
        
       
        snake_length <= 3; head_x <= 5; head_y <= 5; x[1] <= 5; y[1] <= 5; x[2] <= 4; y[2] <= 4;
        repeat (3) @(posedge clk);
        
		  rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        repeat (2) @(posedge clk);
		  
        snake_length <= 3; head_x <= 5; head_y <= 5; x[1] <= 4; y[1] <= 4; x[2] <= 3; y[2] <= 3;
        repeat (3) @(posedge clk);
        repeat (20) @(posedge clk);
		  
        $stop; 
    end 
	 
endmodule 






