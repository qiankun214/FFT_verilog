`ifndef TRAN_WEIG
`define TRAN_WEIG

interface weight_if #(parameter int WIDTH)(input clk);
	logic valid;
	logic [WIDTH - 1:0] data_real;
	logic [WIDTH - 1:0] data_imag;
endinterface : weight_if

class weight_transaction #(parameter int NPOINT);

	shortreal data_real[NPOINT][2 ** (NPOINT - 1)];
	shortreal data_imag[NPOINT][2 ** (NPOINT - 1)];

	function weight_transaction#(NPOINT) copy();
		weight_transaction#(NPOINT) tmp;
		tmp = new();
		for (int i = 0; i < NPOINT; i++) begin
			for (int j = 0; j < 2 ** (NPOINT - 1); j++) begin
				tmp.data_real[i][j] = this.data_real[i][j];
				tmp.data_imag[i][j] = this.data_imag[i][j];
			end
		end
		return tmp;
	endfunction : copy

	function void weight_generater_8();
		for (int i = 0; i < 4; i++) begin
			this.data_real[0][i] = 1;
			this.data_imag[0][i] = 0;
		end

		this.data_real[1][0] = 1;
		this.data_imag[1][0] = 0;
		this.data_real[1][1] = 0;
		this.data_imag[1][1] = -1;
		this.data_real[1][2] = 1;
		this.data_imag[1][2] = 0;
		this.data_real[1][3] = 0;
		this.data_imag[1][3] = -1;

		this.data_real[2][0] = 1;
		this.data_imag[2][0] = 0;
		this.data_real[2][1] = 0.707106;
		this.data_imag[2][1] = -0.707106;
		this.data_real[2][2] = 0;
		this.data_imag[2][2] = -1;
		this.data_real[2][3] = -0.707106;
		this.data_imag[2][3] = -0.707106;
	endfunction : weight_generater_8

endclass : weight_transaction

`endif