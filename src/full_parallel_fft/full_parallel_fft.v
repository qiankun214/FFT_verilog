module full_parallel_fft #(
	parameter NPOINT = 3,
	parameter WIDTH = 16
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// input
	input din_valid,
	output reg din_busy,

	input [WIDTH * (2 ** NPOINT) - 1:0] din_real,
	input [WIDTH * (2 ** NPOINT) - 1:0] din_imag,

	// input [WIDTH * (2 ** NPOINT) - 1- 1:0] op2_real,
	// input [WIDTH * (2 ** NPOINT) - 1- 1:0] op2_imag,

	// output
	output reg dout_valil,
	output reg dout_busy,

	output reg [WIDTH * (2 ** NPOINT) - 1:0] dout_real,
	output reg [WIDTH * (2 ** NPOINT) - 1:0] dout_imag,

	// output reg [WIDTH * (2 ** NPOINT) - 1- 1:0] r2_real,
	// output reg [WIDTH * (2 ** NPOINT) - 1- 1:0] r2_imag
	// weight
	input [WIDTH * (2 ** (NPOINT-1)) - 1:0] din_weight_real,
	input [WIDTH * (2 ** (NPOINT-1)) - 1:0] din_weight_imag
);

endmodule