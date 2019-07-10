
// `include "bu_env.sv"
`include "bu_driver.sv"
`include "bu_monitor.sv"
// `include "bu_transaction.sv"

module bu_top ();

parameter NPOINT = 3;
parameter WIDTH = 16;
parameter STEP = 0;

logic clk,rst_n;
bu_port#( WIDTH * (2 ** NPOINT) ) drv_if(clk);
bu_port#( WIDTH * (2 ** NPOINT) ) mon_if(clk);

logic [WIDTH * (2 ** (NPOINT - 1)) - 1:0] weight_real;
logic [WIDTH * (2 ** (NPOINT - 1)) - 1:0] weight_imag;


butterfly#(
	.WIDTH		(WIDTH	),
	.NPOINT 	(NPOINT ),
	.STEP		(STEP	)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	// input
	.din_valid(drv_if.valid),
	.din_busy(drv_if.busy),

	.din_real(drv_if.data_real),
	.din_imag(drv_if.data_imag),

	// output
	.dout_valil(mon_if.valid),
	.dout_busy(mon_if.busy),

	.dout_real(mon_if.data_real),
	.dout_imag(mon_if.data_imag),

	// weight
	.din_weight_real(weight_real),
	.din_weight_imag(weight_imag)
);

	bu_driver#(NPOINT,WIDTH) drv;
	bu_monitor#(NPOINT,WIDTH) mon;
// bn_env#(NPOINT,WIDTH) tb;

initial begin
	clk = 1'b0;
	forever begin
		#5 clk = ~clk;
	end
end

initial begin
	mon_if.busy = 1'b0;
	rst_n = 1'b1;
	#1 rst_n = 1'b0;
	#1 rst_n = 1'b1;
end
// config
initial begin
	drv = new(drv_if);
	mon = new(mon_if);
	weight_imag = 'b0;
	for (int i = 0; i < 2 ** NPOINT; i++) begin
		weight_real[i * WIDTH +: WIDTH ] = (WIDTH)'(i * 1024);
	end
end

// send
initial begin
	@(posedge clk);
	forever begin
		if(drv.is_noempty()) begin
			drv.send();
		end else begin
			@(posedge clk);
		end
	end
end

// receive
initial begin
	@(posedge clk);
	forever begin
		mon.receive();
	end
end

task case1();
	bu_transaction#(NPOINT) req;
	$display("Case1:begin");
	req = new();
	for (int i = 0; i < 2 ** NPOINT; i++) begin
		req.data_real[i] = 1;
		req.data_imag[i] = 0;
	end
	$display("Case1:data generate finish");
	drv.din(req);
	// $display("Case1:data generate finish");
	do begin
		@(posedge clk);
	end while(!mon.is_noempty());
	req = mon.dout_fifo.pop_front();
	$display("%p",req.data_real);
	$stop;
endtask : case1

initial begin
	@(posedge clk);
	case1();
end

endmodule

