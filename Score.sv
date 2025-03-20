module ScoreKeeper (
    input  logic        clk,         // Clock signal
    input  logic        rst,         // Reset signal
    input  logic        apple_eaten, // Increment score
    input  logic        collision,   // Game over condition
    output logic [7:0]  score,       // Current score (0-255)
    output logic [7:0]  high_score,  // Highest score recorded
    output logic [6:0]  hex0, hex1, hex2, // Current Score (LSB to MSB)
    output logic [6:0]  hex3, hex4, hex5  // High Score (LSB to MSB)
);

    
    logic [3:0] ones, tens, hundreds;
    
    logic [3:0] high_score_ones, high_score_tens, high_score_hundreds;

    
    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            score                <= 8'd0;
				
        end else begin
            if (collision) begin
                // At collision, if current score is greater, update high_score
                if (score > high_score) begin
                    high_score           <= score;
                    
                    high_score_ones      <= ones;
                    high_score_tens      <= tens;
                    high_score_hundreds  <= hundreds;
                end
                score <= 8'd0;  // Reset score after collision.
            end else if (apple_eaten) begin
                if (score < 8'd255)
                    score <= score + 8'd1;  // Increment score (max 255).
            end
        end
    end 

    
    hex_logic score_counter (
        .clk(clk),
        .rst(rst),
        .inc(apple_eaten),
        .ones(ones),
        .tens(tens),
        .hundreds(hundreds)
    );


    HexDisplay hex_disp0 (.value(ones),                .segments(hex0));
    HexDisplay hex_disp1 (.value(tens),                .segments(hex1));
    HexDisplay hex_disp2 (.value(hundreds),            .segments(hex2));
    
    HexDisplay hex_disp3 (.value(high_score_ones),     .segments(hex3));
    HexDisplay hex_disp4 (.value(high_score_tens),     .segments(hex4));
    HexDisplay hex_disp5 (.value(high_score_hundreds), .segments(hex5));

endmodule



module score_testbench();
	logic clk;         
   logic rst;       
   logic apple_eaten; 
   logic collision;  
   logic [7:0]  score;       
   logic [7:0]  high_score;  
   logic [6:0]  hex0, hex1, hex2;
   logic [6:0]  hex3, hex4, hex5;  
	
	ScoreKeeper score_keeper_inst (
        .clk(clk),
        .rst(rst),
        .apple_eaten(apple_eaten),
        .collision(collision),
        .score(score),
        .high_score(high_score),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3),
        .hex4(hex4),
        .hex5(hex5)
    );
	
	parameter CLOCK_PERIOD = 100;
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk;
    end
	 
	 initial begin
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        repeat (2) @(posedge clk);
        
        // Initial movement setup
        collision <= 0;
        repeat (3) @(posedge clk);
        
        // Simulate eating an apple
        apple_eaten <= 1;
        repeat (4) @(posedge clk);
        apple_eaten <= 0;
        repeat (3) @(posedge clk);
        
        // Change direction to left
        repeat (4) @(posedge clk);
        
        // Simulate more movement
        repeat (20) @(posedge clk);
		  
		  collision <= 1;
		  collision <= 0;
		  apple_eaten <= 1;
        repeat (20) @(posedge clk);
        apple_eaten <= 0;
        repeat (3) @(posedge clk);
        repeat (20) @(posedge clk);
		  
        $stop; 
    end 
endmodule  
