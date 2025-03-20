module hex_logic (
    input  logic clk,
    input  logic rst,
    input  logic inc,         // Increment pulse
    output logic [3:0] ones,    // Ones digit (0-9)
    output logic [3:0] tens,    // Tens digit (0-9)
    output logic [3:0] hundreds // Hundreds digit (0-1, but only 0 or 1 will appear)\
//	 output logic [3:0] high_score_ones,
//	 output logic [3:0] high_score_tens,
//	 output logic [3:0] high_score_hundreds
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ones     <= 4'd0;
            tens     <= 4'd0;
            hundreds <= 4'd0;
				
        end else if (inc) begin
            // If we have reached 128, reset the counter.
            if (hundreds == 4'd2 && tens == 4'd5 && ones == 4'd6) begin
                ones     <= 4'd0;
                tens     <= 4'd0;
                hundreds <= 4'd0;

            end else if (ones < 4'd9) begin
                ones <= ones + 4'd1;
//					 high_score_ones <= ones;
            end else begin
                // ones is 9, so reset ones and carry over to tens.
                ones <= 4'd0;
//					 high_score_ones <= ones;
					 
                if (tens < 4'd9) begin
                    tens <= tens + 4'd1;
//						  high_score_tens <= tens;
                end else begin
                    // Carry from tens to hundreds.
                    tens     <= 4'd0;
//						  high_score_tens <= tens;
                    hundreds <= hundreds + 4'd1;
//						  high_score_hundreds <= hundreds;
                end
            end
        end
    end

endmodule

