module tb_fpga_fft_acc (
);
	
parameter NPOINT = 3;

logic clk;
logic rst_n;
logic fx2_flaga;
logic fx2_flagb;
logic fx2_flagc;
logic fx2_flagd;
logic fx2_slcs_n;
logic fx2_slwr_n;
logic fx2_slrd_n;
logic fx2_sloe_n;
logic fx2_pktend_n;
logic [1:0]fx2_a;
wire [15:0]fx2_db;
logic [15:0] fx2_db_din;

fpga_fft_acc #(
	.NPOINT(NPOINT)
) dut (

	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low
	
	
	.fx2_flaga(fx2_flaga),
	.fx2_flagb(fx2_flagb),
	.fx2_flagc(fx2_flagc),
	.fx2_flagd(fx2_flagd),

	.fx2_slcs_n(fx2_slcs_n),
	.fx2_slwr_n(fx2_slwr_n),
	.fx2_slrd_n(fx2_slrd_n),
	.fx2_sloe_n(fx2_sloe_n),
	.fx2_pktend_n(fx2_pktend_n),
	.fx2_a(fx2_a),

	.fx2_db(fx2_db)	
);

assign fx2_db = (fx2_sloe_n)?'bz:fx2_db_din;

initial begin
	clk = 1'b0;
	forever begin
		#5 clk = ~clk;
	end
end

initial begin
	fx2_flagb = 1'b1;
	fx2_flagc = 'b0;
	fx2_flagd = 'b0;
	rst_n = 1'b1;
	#1 rst_n = 1'b0;
	#1 rst_n = 1'b1;
end

logic [15:0] din_fifo[$];
initial begin
	fx2_db_din = 'b0;
	fx2_flaga = 1'b0;
	forever begin
		@(posedge clk);
		if(!fx2_slcs_n && !fx2_slrd_n && fx2_flaga) begin
			if(din_fifo.size() != 0) begin
				fx2_db_din = din_fifo.pop_front();
				fx2_flaga = 1'b1;
			end
		end else if(din_fifo.size() != 0) begin
			fx2_flaga = 1'b1;
		end else begin
			fx2_flaga = 1'b0;
		end
	end
end

initial begin
	for (int i = NPOINT-1; i >= 0; i--) begin
		for (int j = 2 ** (NPOINT-1) - 1; j >= 0; j--) begin
			din_fifo.push_back({4'd0,(4)'(i),(4)'(j),4'd0});
			din_fifo.push_back({4'd0,(4)'(i),(4)'(j),4'd0});
		end
	end
end

endmodule