// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output logic [9:0]  LEDR,
    input  logic [3:0]  KEY,
    input  logic [9:0]  SW,
    output logic [35:0] GPIO_1,
    input logic CLOCK_50
);

//    assign HEX5 = '1;

    /* Clock Setup 
       =============================================== */
    logic [31:0] clk;
    logic SYSTEM_CLOCK, snake_clock;

    clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));

    assign SYSTEM_CLOCK = clk[14];  // 1526 Hz for LED refresh
    assign snake_clock  = clk[22];  
	 
    /* LED Driver Setup
       =============================================== */
    logic [15:0][15:0] RedPixels; // Red LEDs
    logic [15:0][15:0] GrnPixels; // Green LEDs
    logic RST;

    assign RST = SW[9];

    LEDDriver Driver (
        .CLK(SYSTEM_CLOCK), 
        .RST(RST), 
        .EnableCount(1'b1), 
        .RedPixels(RedPixels), 
        .GrnPixels(GrnPixels), 
        .GPIO_1(GPIO_1)
    );

    /* Input Handling (Metastability Protection)
       =============================================== */
    logic key0, key1, key2, key3;
    logic key0_from_dff, key1_from_dff, key2_from_dff, key3_from_dff;

    doubleFlip ff1 (.clk(SYSTEM_CLOCK), .rst(RST), .key(~KEY[0]), .out(key0_from_dff));
    doubleFlip ff2 (.clk(SYSTEM_CLOCK), .rst(RST), .key(~KEY[1]), .out(key1_from_dff));
    doubleFlip ff3 (.clk(SYSTEM_CLOCK), .rst(RST), .key(~KEY[2]), .out(key2_from_dff));
    doubleFlip ff4 (.clk(SYSTEM_CLOCK), .rst(RST), .key(~KEY[3]), .out(key3_from_dff));

    UserInput button1 (.clk(SYSTEM_CLOCK), .rst(RST), .key(key0_from_dff), .out(key0)); 
    UserInput button2 (.clk(SYSTEM_CLOCK), .rst(RST), .key(key1_from_dff), .out(key1));
    UserInput button3 (.clk(SYSTEM_CLOCK), .rst(RST), .key(key2_from_dff), .out(key2)); 
    UserInput button4 (.clk(SYSTEM_CLOCK), .rst(RST), .key(key3_from_dff), .out(key3));

    logic [1:0] the_direction;
	 
    movementInput snakeInput (
        .clk(SYSTEM_CLOCK), 
        .rst(RST), 
        .L(key2), 
        .R(key1), 
        .U(key0), 
        .D(key3), 
        .direction(the_direction)
    );

    /* Random Apple Generation
       =============================================== */
    logic [15:0] lfsr_out;
	 
    LFSR random_apples (
        .clk(snake_clock), 
        .rst(RST), 
        .Q(lfsr_out)
    );

    logic eaten;
    logic [3:0] x_apple, y_apple;
    logic [3:0] x_head, y_head;
    logic [7:0] length_snake;
    logic any_collision;

    logic [3:0] x[0:127], y[0:127];

    apples apple (
        .clk(snake_clock), 
        .rst(RST), 
        .Q(lfsr_out), 
        .head_x(x_head), 
        .head_y(y_head), 
        .collision(any_collision), 
        .apple_eaten(eaten), 
        .apple_x(x_apple), 
        .apple_y(y_apple)
    );

    /* Snake Module
       =============================================== */
    snake theSnake (
		 .clk(snake_clock), 
		 .rst(RST), 
		 .direction(the_direction), 
		 .apple_eaten(eaten), 
		 .apple_x(x_apple),        
		 .apple_y(y_apple),        
		 .head_x(x_head), 
		 .head_y(y_head), 
		 .RedPixels(RedPixels), 
		 .GrnPixels(GrnPixels), 
		 .snake_length(length_snake), 
		 .collision(any_collision),
		 .x(x), 
		 .y(y)  
	);


    /* Collision Detection
       =============================================== */
    collision collision_inst (
		 .clk(SYSTEM_CLOCK),
		 .rst(RST),
		 .head_x(x_head),
		 .head_y(y_head),
		 .x(x),   
		 .y(y),   
		 .snake_length(length_snake),
		 .collision(any_collision)
	);
	
	ScoreKeeper score_keeper_inst (
        .clk(snake_clock),
        .rst(RST),
        .apple_eaten(eaten),
        .collision(any_collision),
        .score(score),
        .high_score(high_score),
        .hex0(HEX0),
        .hex1(HEX1),
        .hex2(HEX2),
        .hex3(HEX3),
        .hex4(HEX4),
        .hex5(HEX5)
    );


endmodule

module DE1_SoC_testbench();
   logic 		CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_1;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR, .KEY, .SW, .GPIO_1, .CLOCK_50);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2)
		CLOCK_50 <= ~CLOCK_50;
	end
    
    // Test sequence
    initial begin
        SW[9] <= 1;
        repeat (10) @(posedge CLOCK_50);
        SW[9] <= 0;
		  
		  KEY[0] <= 0; KEY[1] <= 0; KEY[2] <= 0; KEY[3] <= 0;
        repeat (2) @(posedge CLOCK_50);
        
        KEY[0] <= 1;
        repeat (100) @(posedge CLOCK_50);
		  
		  KEY[0] <= 0;
        repeat (100) @(posedge CLOCK_50);
        
        KEY[1] <= 1;
        repeat (100) @(posedge CLOCK_50);
		  
		  KEY[1] <= 0;
        repeat (100) @(posedge CLOCK_50);
        
        KEY[3] <= 1;
        repeat (100) @(posedge CLOCK_50);
		  
		  KEY[3] <= 0;
        repeat (100) @(posedge CLOCK_50);
		  
		  SW[9] <= 0;
        repeat (100) @(posedge CLOCK_50);
        SW[9] <= 0;
        
        KEY[2] <= 1;
        repeat (100) @(posedge CLOCK_50);
		  
        $stop; 
    end 
endmodule  


