module butterfly#(
	parameter WIDTH = 16,
	parameter NPOINT = 3,
	parameter STEP = 2
) (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// input
	input din_valid,
	output reg din_busy,

	input [WIDTH * (2 ** NPOINT) - 1:0] din_real,
	input [WIDTH * (2 ** NPOINT) - 1- 1:0] din_imag,

	// input [WIDTH * (2 ** NPOINT) - 1- 1:0] op2_real,
	// input [WIDTH * (2 ** NPOINT) - 1- 1:0] op2_imag,

	// output
	output reg dout_valil,
	output reg dout_busy,

	output reg [WIDTH * (2 ** NPOINT) - 1- 1:0] dout_real,
	output reg [WIDTH * (2 ** NPOINT) - 1- 1:0] dout_imag,

	// output reg [WIDTH * (2 ** NPOINT) - 1- 1:0] r2_real,
	// output reg [WIDTH * (2 ** NPOINT) - 1- 1:0] r2_imag
);

localparam GL = 2 ** STEP;

// split
genvar split_i;
wire [WIDTH - 1:0] din_data_real [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] din_data_imag [2 ** NPOINT - 1:0];

wire signed [WIDTH - 1:0] butterfly_op1_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_op1_imag [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_op2_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_op2_imag [2 ** (NPOINT - 1) - 1:0];
generate
	for (int split_i = 0; split_i < 2 ** NPOINT; split_i++) begin:split_din
		assign din_data_real[split_i] = din_real[split_i * WIDTH +: WIDTH];
		assign din_data_imag[split_i] = din_imag[split_i * WIDTH +: WIDTH];
	end

	for (int split_i = 0; split_i < 2 ** (NPOINT - 1); split_i++) begin:con_din
		assign butterfly_op1_real[split_i] = din_data_real[ (split_i >> STEP) * 2 * GL + split_i % GL ];
		assign butterfly_op1_imag[split_i] = din_data_imag[ (split_i >> STEP) * 2 * GL + split_i % GL ];
		assign butterfly_op2_real[split_i] = din_data_real[ (split_i >> STEP) * 2 * GL + split_i % GL + GL ];
		assign butterfly_op2_imag[split_i] = din_data_imag[ (split_i >> STEP) * 2 * GL + split_i % GL + GL ];
	end
endgenerate

wire signed [WIDTH - 1:0] butterfly_r1_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_r1_imag [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_r2_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_r2_imag [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_tmp_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_tmp_imag [2 ** (NPOINT - 1) - 1:0];
genvar compute_i;
generate
	for (int compute_i = 0; compute_i < 2 ** (NPOINT - 1); compute_i++) begin:compute
		
		wire signed [2 * WIDTH - 1:0] tmp11 = weight_real * butterfly_op2_real;
		wire signed [2 * WIDTH - 1:0] tmp12 = weight_imag * butterfly_op2_imag;
		wire signed [2 * WIDTH - 1:0] tmp21 = weight_imag * butterfly_op2_real;
		wire signed [2 * WIDTH - 1:0] tmp21 = weight_real * butterfly_op2_imag;

		assign butterfly_tmp_real = tmp11[WIDTH - 1:0] - tmp12[WIDTH - 1:0]; 
		assign butterfly_tmp_imag = tmp21[WIDTH - 1:0] + tmp22[WIDTH - 1:0];

		assign butterfly_r1_real = butterfly_tmp_real + butterfly_r1_real;
		assign butterfly_r1_imag = butterfly_tmp_imag + butterfly_r1_imag;

		assign butterfly_r1_real = butterfly_r1_real - butterfly_tmp_real;
		assign butterfly_r1_imag = butterfly_r1_imag - butterfly_tmp_imag;

	end
endgenerate

// allocation
genvar allocation_i;
wire [WIDTH - 1:0] dout_data_real [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] dout_data_imag [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] dout_real_com [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] dout_imag_com [2 ** NPOINT - 1:0];
generate
	for (int allocation_i = 0; allocation_i < 2 ** (NPOINT - 1); allocation_i++) begin:allocation_dout
		assign dout_data_real[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL ] 		= 	butterfly_r1_real[allocation_i];
		assign dout_data_imag[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL ] 		= 	butterfly_r1_imag[allocation_i];
		assign dout_data_real[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL + GL ] 	= 	butterfly_r2_real[allocation_i];
		assign dout_data_imag[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL + GL ] 	= 	butterfly_r2_imag[allocation_i];
	end

	for (int allocation_i = 0; allocation_i < 2 ** NPOINT; allocation_i++) begin:assign_dout
		assign dout_real_com[allocation_i * WIDTH +: WIDTH] = dout_data_real[allocation_i];
		assign dout_imag_com[allocation_i * WIDTH +: WIDTH] = dout_data_imag[allocation_i];
	end
endgenerate


endmodule
