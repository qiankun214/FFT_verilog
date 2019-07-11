`ifndef TRAN_WEIG
`define TRAN_WEIG

interface weight_if #(parameter int WEIG_WIDTH)(input clk);
	logic valid;
	logic [WIDTH - 1:0] data_real;
	logic [WIDTH - 1:0] data_imag;
endinterface : weight_if

class weight_transaction #(parameter int NPOINT);

	shortreal weight_real[NPOINT][2 ** (NPOINT - 1)];
	shortreal weight_imag[NPOINT][2 ** (NPOINT - 1)];

	function weight_transaction#(NPOINT) copy();
		weight_transaction#(NPOINT) tmp;
		tmp = new();
		for (int i = 0; i < NPOINT; i++) begin
			for (int j = 0; j < 2 ** (NPOINT - 1); j++) begin
				tmp.weight_real[i][j] = this.weight_real[i][j];
				tmp.weight_imag[i][j] = this.weight_imag[i][j];
			end
		end
		return tmp;
	endfunction : copy

endclass : weight_transaction

`endif