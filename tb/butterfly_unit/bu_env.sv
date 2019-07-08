`ifndef ENV_BU
`define ENV_BU

`include "bu_driver.sv"
`include "bu_monitor.sv"

class bu_env #(parameter int NPOINT,parameter int WIDTH);

	bu_driver#(NPOINT,WIDTH) drv;
	bu_monitor#(NPOINT,WIDTH) mon;

	function new (virtual bu_port#((2 ** NPOINT) * WIDTH) drv_if,mon_if);
		drv = new(drv_if);
		mon = new(mon_if);
	endfunction

endclass : bu_env

`endif