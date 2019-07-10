`ifndef MON_BU
`define MON_BU

`include "bu_transaction.sv"

class bu_monitor #(parameter int NPOINT,parameter int WIDTH);

	bu_transaction#(NPOINT) dout_fifo	[$];
	virtual bu_port#((2 ** NPOINT) * WIDTH) my_port;

	function new( virtual bu_port#((2 ** NPOINT) * WIDTH) my_if);
		my_port = my_if;
		my_port.busy = 1'b0;
		$display("MON:build finish");
	endfunction

	function bu_transaction#(NPOINT) dout(bu_trans);
		return dout_fifo.pop_front();
	endfunction

	function logic is_noempty();
		if ( dout_fifo.size() == 0 ) begin
			return 1'b0;
		end	else begin
			return 1'b1;
		end
	endfunction

	task receive();
		if(my_port.valid && !my_port.busy) begin
			bu_transaction#(NPOINT) tmp;
			tmp = new();
			$display("MON:get one req start");
			for (int i = 0; i < 2 ** NPOINT; i++) begin
				if(my_port.data_real[WIDTH*i + WIDTH - 1]) begin
					tmp.data_real[i] = shortreal'(my_port.data_real[WIDTH*i +: WIDTH]) / 1024 - 64;
				end else begin
					tmp.data_real[i] = shortreal'(my_port.data_real[WIDTH*i +: WIDTH]) / 1024;
				end
				$display("MON %0d:%0d",i,tmp.data_real[i]);
				tmp.data_imag[i] = my_port.data_imag[WIDTH*i +: WIDTH] / 1024;
			end
			$display("MON:get one req finish");
			dout_fifo.push_back(tmp);
		end
		@(posedge my_port.clk);
	endtask : receive

endclass : bu_monitor

`endif