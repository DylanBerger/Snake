module doubleFlip (key, out, clk, rst);

input logic clk, rst, key;
output logic out;

logic DFF_out;

	always_ff @(posedge clk) begin
        DFF_out <= key;  
        out <= DFF_out;  
    end
	 
endmodule