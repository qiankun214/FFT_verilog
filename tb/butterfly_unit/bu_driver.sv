
`ifndef DRV_BU
`define DRV_BU

`include "bu_transaction.sv"

class bu_driver #(parameter int NPOINT,parameter int WIDTH);

	bu_transaction#(NPOINT) din_fifo [$];
	virtual bu_port#((2 ** NPOINT) * WIDTH) my_port;

	function new ( virtual bu_port#((2 ** NPOINT) * WIDTH) my_if );
		my_port = my_if;
		my_port.valid = 1'b0;
		my_port.data_real = 'b0;
		my_port.data_imag = 'b0;
		$display("DRV:build finish");
	endfunction 

	function void din(bu_transaction#(NPOINT) data);
		$display("DRV:get one req");
		din_fifo.push_back(data.copy());
	endfunction : din

	function logic is_noempty();
		if( din_fifo.size() == 0) begin
			return 1'b0;
		end else begin
			return 1'b1;
		end
	endfunction : is_noempty

	task send();
		bu_transaction#(NPOINT) tmp;
		$display("DRV:start one req");
		tmp = din_fifo.pop_front();
		for (int i = 0; i < 2 ** NPOINT; i++) begin
			if(tmp.data_real[i] >= 0) begin
				my_port.data_real[i*WIDTH +: WIDTH] = int'(tmp.data_real[i] * 1024);
			end else begin
				my_port.data_real[i*WIDTH +: WIDTH] = 2 ** WIDTH + int'(tmp.data_real[i] * 1024);
			end

			if(tmp.data_imag[i] >= 0) begin
				my_port.data_imag[i*WIDTH +: WIDTH] = int'(tmp.data_imag[i] * 1024);
			end else begin
				my_port.data_imag[i*WIDTH +: WIDTH] = 2 ** WIDTH + int'(tmp.data_imag[i] * 1024);
			end
		end
		my_port.valid = 1'b1;
		do begin
			@(posedge my_port.clk);
		end while(my_port.busy);
		my_port.valid = 'b0;
		$display("DRV:finish one req");
	endtask : send

endclass : bu_driver

`endif
 
