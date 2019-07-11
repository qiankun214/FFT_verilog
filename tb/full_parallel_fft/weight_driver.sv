`ifndef DRV_WEIG
`define DRV_WEIG

`include "weight_transaction.sv"

class weight_driver #(parameter int NPOINT,parameter int WIDTH);

	virtual weight_if#(WIDTH) weight_port;

	function new(virtual weight_if#(WIDTH) my_if);
		weight_port = my_if;
		weight_port.valid = 'b0;
		weight_port.data_real = 'b0;
		weight_port.data_imag = 'b0;
	endfunction : new

	task cfg(weight_transaction#(NPOINT) cfg_pkg);
		for (int i = NPOINT - 1; i >= 0; i--) begin
			for (int j = 2 ** (NPOINT - 1) - 1; j >= 0; j--) begin
				$display("WEGH:once");
				if(cfg_pkg.data_real[i][j] >= 0) begin
					weight_port.data_real = int'(cfg_pkg.data_real[i][j] * 1024);
				end else begin
					weight_port.data_real = 2 ** WIDTH + int'(cfg_pkg.data_real[i][j] * 1024);
				end
	
				if(cfg_pkg.data_imag[i][j] >= 0) begin
					weight_port.data_imag = int'(cfg_pkg.data_imag[i][j] * 1024);
				end else begin
					weight_port.data_imag = 2 ** WIDTH + int'(cfg_pkg.data_imag[i][j] * 1024);
				end
				weight_port.valid = 1'b1;
				@(posedge weight_port.clk);
			end
			weight_port.valid = 1'b0;
		end
	endtask : cfg

endclass : weight_driver

`endif