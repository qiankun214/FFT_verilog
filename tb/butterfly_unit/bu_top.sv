`include "bu_env.sv"

module bu_top (
);

parameter NPOINT = 3;
parameter WIDTH = 16;
parameter STEP = 0;

bn_env env;

logic clk,rst_n;
bu_port#( WIDTH * (2 ** NPOINT) ) drv_if(clk);
bu_port#( WIDTH * (2 ** NPOINT) ) mon_if(clk);

logic [WIDTH * (2 ** NPOINT) - 1:0] weight_real;
logic [WIDTH * (2 ** NPOINT) - 1:0] weight_imag;

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

	.din_real(drv_if.real),
	.din_imag(drv_if.imag),

	// output
	.dout_valil(mon_if.valid),
	.dout_busy(mon_if.busy),

	.dout_real(mon_if.real),
	.dout_imag(mon_if.imag),

	// weight
	.din_weight_real(),
	.din_weight_imag()
);

// config
initial begin
	env = new(drv_if,mon_if);
	weight_imag = 'b0;
	for (int i = 0; i < 2 ** NPOINT; i++) begin
		weight_real[i * WIDTH +: WIDTH ] = (WIDTH)'(i);
	end
end

// send
initial begin
	@(posedge clk);
	forever begin
		if(env.drv.is_noempty()) begin
			env.drv.send();
		end else begin
			@(posedge clk);
		end
	end
end

// receive
initial begin
	@(posedge clk);
	forever begin
		env.mon.receive();
	end
end

task case1();
	bu_transaction req;
	req = new();
	for (int i = 0; i < 2 ** NPOINT; i++) begin
		req.data_real[i] = 1;
		req.data_imag[i] = 0;
	end
	env.drv.din(req);
	do begin
		@(posedge clk);
	end while(!env.mon.is_noempty());
	req = env.mon.dout_fifo.pop_front()
	$display("%p",req.data_real);
	$stop;
endtask : case1

initial begin
	@(posedge clk);
	case1();
end

endmodule

