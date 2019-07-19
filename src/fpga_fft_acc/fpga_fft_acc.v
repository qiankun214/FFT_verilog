module fpga_fft_acc #(parameter NPOINT = 3)(

	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	// cy
	input fx2_flaga,
	input fx2_flagb,
	input fx2_flagc,
	input fx2_flagd,

	output fx2_slcs_n,
	output fx2_slwr_n,
	output fx2_slrd_n,
	output fx2_sloe_n,
	output fx2_pktend_n,
	output [1:0]fx2_a,

	inout [15:0] fx2_db	
);

wire fft_weight_valid;
wire [15:0]fft_weight_real;
wire [15:0]fft_weight_imag;

wire fft_din_valid;
wire fft_din_busy;
wire [16 * (2 ** NPOINT) - 1:0] fft_din_real;
wire [16 * (2 ** NPOINT) - 1:0] fft_din_imag;

wire fft_dout_valid;
wire fft_dout_busy;
wire [16 * (2 ** NPOINT) - 1:0] fft_dout_real;
wire [16 * (2 ** NPOINT) - 1:0] fft_dout_imag;

usb_interface #(
	.NPOINT(NPOINT)
) u_usb_if (
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


full_parallel_fft #(
	.NPOINT(NPOINT),
	.WIDTH(16)
) u_fft (
	.clk(clk),
	.rst_n(rst_n),

	// input,
	.din_valid(fft_din_valid),
	.din_busy(fft_din_busy),

	.din_real(fft_din_real),
	.din_imag(fft_din_imag),

	// output,
	.dout_valil(fft_dout_valid),
	.dout_busy(fft_dout_busy),

	.dout_real(fft_dout_real),
	.dout_imag(fft_dout_imag),

	.din_weight_valid(fft_weight_valid),
	.din_weight_real(fft_weight_real),
	.din_weight_imag(fft_weight_imag)
);

endmodule