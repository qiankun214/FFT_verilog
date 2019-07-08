`ifndef ENV_BU
`define ENV_BU

`include "bu_driver.sv"
`include "bu_monitor.sv"

class bu_env #(parameter int NPOINT = 3,parameter int WIDTH = 16);

	bu_driver#(NPOINT,WIDTH) drv;
	bu_monitor#(NPOINT,WIDTH) mon;

	function new (virtual bu_port#((2 ** NPOINT) * WIDTH) drv_if,virtual bu_port#((2 ** NPOINT) * WIDTH) mon_if);
		drv = new(drv_if);
		mon = new(mon_if);
	endfunction

endclass : bu_env

`endif