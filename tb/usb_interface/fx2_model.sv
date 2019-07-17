`ifndef MODEL_FX2
`define MODEL_FX2

interface fx2_port (logic clk);

	logic fx2_flaga,
	logic fx2_flagb,
	logic fx2_flagc,
	logic fx2_flagd,

	logic fx2_slcs_n,
	logic fx2_slwr_n,
	logic fx2_slrd_n,
	logic fx2_sloe_n,
	logic [1:0]fx2_a,

	logic [15:0] fx2_db,

endinterface : fx2_port

class fx2_model #(parameter int NPOINT);



endclass : fx2_model

`endif