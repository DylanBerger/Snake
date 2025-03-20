module UserInput(key, out, clk, rst);
	output logic out;
	input logic clk, rst, key;
	
	enum {on, off} ps, ns;
	
	always_comb begin
		case(ps)
		
			on: 	if(key) ns = on;
						
					else ns = off;
						//out = 1
				
			off: 	if(key) ns = on;
					
					else ns = off;

			
		endcase
	end
	
	assign out = (ps == on & ns == off);
	
	always_ff @(posedge clk) begin
		if(rst) 
			ps <= off;
		else
			ps <= ns;
	end
endmodule
