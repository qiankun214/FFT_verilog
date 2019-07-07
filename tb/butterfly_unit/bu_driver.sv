
`ifndef DRV_BU
`define DRV_BU

`include "bu_transaction.sv"

interface bu_port #(parameter int WIDTH) (logic clk);
	logic valid;
	logic busy;
	logic [WIDTH - 1:0] data_real;
	logic [WIDTH - 1:0] data_imag; 
endinterface : bu_port

class bu_driver #(parameter int NPOINT,parameter int WIDTH);

	bu_transaction din_fifo [$];
	virtual bu_port#((2 ** NPOINT) * WIDTH) my_port;

	function new ( virtual bu_port my_if );
		my_port = my_if;
		my_port.valid = 1'b0;
		my_port.data = 'b0;
	endfunction 

	function void din(bu_transaction data);
		din_fifo.push_back(data.copy());
	endfunction : din

	task work();
		bu_transaction tmp;
		tmp = din_fifo.pop_front();
		for (int i = 0; i < 2 ** NPOINT; i++) begin
			my_port.data_real[i*WIDTH +: WIDTH] = tmp.data_real[i];
			my_port.data_imag[i*WIDTH +: WIDTH] = tmp.data_imag[i];
		end
		my_port.valid = 1'b1;
		do begin
			@(my_port.clk);
		end while(my_port.busy);
		my_port.valid = 'b0;
	endtask : work

endclass : bu_driver

`endif
 
