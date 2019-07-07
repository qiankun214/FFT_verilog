
`ifndef TRAN_BN
`define TRAN_BN

class bu_transaction #(parameter int NPOINT);

	integer data_real [2 ** NPOINT - 1:0];
	integer data_imag [2 ** NPOINT - 1:0];

	function bu_transaction copy ();
		bu_transaction#(NPOINT) tmp;
		tmp = new();
		for (int i = 0; i < 2 ** NPOINT; i++) begin
			tmp.data_real[i] = this.data_real[i];
			tmp.data_imag[i] = this.data_imag[i];
		end
		return tmp
	endfunction

endclass : bu_transaction

`endif