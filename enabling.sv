module enabling (clock, reset, enable);


	input logic reset, clock;
	output logic enable;

	`ifdef ALTERA_RESERVED_QIS
	logic [5:0] divided_clocks = 0;

	`else
	logic [2:0] divided_clocks = 0;

	`endif

	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end

	assign enable = (divided_clocks == 0);

endmodule
