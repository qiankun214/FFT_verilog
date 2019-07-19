module tb_usb_interface (
);

parameter NPOINT = 3;

logic clk;
logic rst_n;

// cy
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
wire [15:0] fx2_db;

// inter
logic fft_weight_valid;
logic [15:0]fft_weight_real;
logic [15:0]fft_weight_imag;
logic fft_din_valid;
logic fft_din_busy;
logic [16 * (2 ** NPOINT) - 1:0] fft_din_real;
logic [16 * (2 ** NPOINT) - 1:0] fft_din_imag;
logic fft_dout_valid;
logic fft_dout_busy;
logic [16 * (2 ** NPOINT) - 1:0] fft_dout_real;
logic [16 * (2 ** NPOINT) - 1:0] fft_dout_imag;

usb_interface #(
	.NPOINT(NPOINT)
) dut (
	// system
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low
	
	// fx2
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

	.fx2_db(fx2_db),

	// inter
	.fft_weight_valid(fft_weight_valid),
	.fft_weight_real(fft_weight_real),
	.fft_weight_imag(fft_weight_imag),

	.fft_din_valid(fft_din_valid),
	.fft_din_busy(fft_din_busy),
	.fft_din_real(fft_din_real),
	.fft_din_imag(fft_din_imag),

	.fft_dout_valid(fft_dout_valid),
	.fft_dout_busy(fft_dout_busy),
	.fft_dout_real(fft_dout_real),
	.fft_dout_imag(fft_dout_imag)
);

logic is_out;
initial begin
	fx2_flaga = 'b0;
	fx2_flagb = 1'b1;
	fx2_flagc = 'b0;
	fx2_flagd = 'b0;
	fft_din_busy = 'b0;
	fft_dout_valid = 'b0;
	fft_dout_real = 'b0;
	fft_dout_imag = 'b0;
	#1000 fx2_flaga = 1'b1;
	is_out = 1'b0;
end

assign fx2_db = (is_out)?16'hz:16'h1234;

initial begin
	clk = 'b0;
	forever begin
		#5 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	#1 rst_n = 1'b0;
	#1 rst_n = 1'b1;
end

initial begin
	#10000;
	fft_dout_real = 128'h0123456789abcdef0123456789abcdef;
	fft_dout_imag = 128'hfedcba9876543210fedcba9876543210;
	fft_dout_valid = 1'b1;
	is_out = 1'b1;
	@(posedge clk);
	fft_dout_valid = 1'b0;
end

endmodule
