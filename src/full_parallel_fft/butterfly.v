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
	// weight
	input [WIDTH * (2 ** (NPOINT-1)) - 1:0] din_weight_real,
	input [WIDTH * (2 ** (NPOINT-1)) - 1:0] din_weight_imag
);

localparam GL = 2 ** STEP;

wire din_tran = din_valid && !din_busy;
wire dout_tran = dout_valil && !dout_busy;

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		din_busy <= 'b0;
	end else if(din_tran) begin
		din_busy <= 1'b1;
	end else if(dout_tran) begin
		din_busy <= 'b0;
	end
end

reg din_valid_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		din_valid_lock <= 'b0;
	end else begin
		din_valid_lock <= din_tran;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout_valil <= 'b0;
	end else if(din_valid_lock) begin
		dout_valil <= 1'b1;
	end else if(dout_tran) begin
		dout_valil <= 'b0;
	end
end

// input reshape
genvar input_i;
wire [WIDTH - 1:0] this_data_real [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] this_data_imag [2 ** NPOINT - 1:0];
// generate
// 	if(STEP == 0) begin:is_first
// 		for (input_i = 0; input_i < 2 ** NPOINT; input_i++) begin:reshape_din
// 			// wire [NPOINT - 1:0]tmp = input_i;
// 			assign this_data_real[input_i[0:NPOINT-1] * WIDTH +: WIDTH] = din_real[input_i * WIDTH +: WIDTH];
// 			assign this_data_real[input_i[0:NPOINT-1] * WIDTH +: WIDTH] = din_imag[input_i * WIDTH +: WIDTH];
// 		end
// 	end else begin
		assign this_data_real = din_real;
		assign this_data_imag = din_imag;
// 	end
// endgenerate


// split
genvar split_i;
wire [WIDTH - 1:0] din_data_real [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] din_data_imag [2 ** NPOINT - 1:0];

wire signed [WIDTH - 1:0] weight_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] weight_imag [2 ** (NPOINT - 1) - 1:0];

wire signed [WIDTH - 1:0] butterfly_op1_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_op1_imag [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_op2_real [2 ** (NPOINT - 1) - 1:0];
wire signed [WIDTH - 1:0] butterfly_op2_imag [2 ** (NPOINT - 1) - 1:0];
generate
	for (split_i = 0; split_i < 2 ** NPOINT; split_i++) begin:split_din
		assign din_data_real[split_i] = this_data_real[split_i * WIDTH +: WIDTH];
		assign din_data_imag[split_i] = this_data_imag[split_i * WIDTH +: WIDTH];
	end

	for (split_i = 0; split_i < 2 ** (NPOINT - 1); split_i++) begin:con_din
		assign weight_real[split_i]		   = din_weight_real[ split_i*WIDTH +: WIDTH ];
		assign weight_imag[split_i]		   = din_weight_imag[ split_i*WIDTH +: WIDTH ];
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
reg signed [WIDTH - 1:0] butterfly_tmp_real [2 ** (NPOINT - 1) - 1:0];
reg signed [WIDTH - 1:0] butterfly_tmp_imag [2 ** (NPOINT - 1) - 1:0];
genvar compute_i;
generate
	for (compute_i = 0; compute_i < 2 ** (NPOINT - 1); compute_i++) begin:compute
		
		wire signed [2 * WIDTH - 1:0] tmp11 = weight_real * butterfly_op2_real[compute_i];
		wire signed [2 * WIDTH - 1:0] tmp12 = weight_imag * butterfly_op2_imag[compute_i];
		wire signed [2 * WIDTH - 1:0] tmp21 = weight_imag * butterfly_op2_real[compute_i];
		wire signed [2 * WIDTH - 1:0] tmp21 = weight_real * butterfly_op2_imag[compute_i];

		always @(posedge clk or negedge rst_n) begin
			if(~rst_n) begin
			 	butterfly_tmp_real[compute_i] <= 'b0;
			 	butterfly_tmp_imag[compute_i] <= 'b0;
			end else begin
			 	butterfly_tmp_real[compute_i] <= tmp11[WIDTH +: WIDTH] - tmp12[WIDTH +: WIDTH];
			 	butterfly_tmp_imag[compute_i] <= tmp21[WIDTH +: WIDTH] + tmp22[WIDTH +: WIDTH];
			end
		end

		assign butterfly_r1_real[compute_i] = butterfly_tmp_real[compute_i] + butterfly_op1_real[compute_i];
		assign butterfly_r1_imag[compute_i] = butterfly_tmp_imag[compute_i] + butterfly_op1_imag[compute_i];

		assign butterfly_r1_real[compute_i] = butterfly_op1_real[compute_i] - butterfly_tmp_real[compute_i];
		assign butterfly_r1_imag[compute_i] = butterfly_op1_imag[compute_i] - butterfly_tmp_imag[compute_i];

	end
endgenerate

// allocation
genvar allocation_i;
wire [WIDTH - 1:0] dout_data_real [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] dout_data_imag [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] dout_real_com [2 ** NPOINT - 1:0];
wire [WIDTH - 1:0] dout_imag_com [2 ** NPOINT - 1:0];
generate
	for (allocation_i = 0; allocation_i < 2 ** (NPOINT - 1); allocation_i++) begin:allocation_dout
		assign dout_data_real[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL ] 		= 	butterfly_r1_real[allocation_i];
		assign dout_data_imag[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL ] 		= 	butterfly_r1_imag[allocation_i];
		assign dout_data_real[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL + GL ] 	= 	butterfly_r2_real[allocation_i];
		assign dout_data_imag[ (allocation_i >> STEP) * 2 * GL + allocation_i % GL + GL ] 	= 	butterfly_r2_imag[allocation_i];
	end

	for (allocation_i = 0; allocation_i < 2 ** NPOINT; allocation_i++) begin:assign_dout
		assign dout_real_com[allocation_i * WIDTH +: WIDTH] = dout_data_real[allocation_i];
		assign dout_imag_com[allocation_i * WIDTH +: WIDTH] = dout_data_imag[allocation_i];
	end
endgenerate

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout_real <= 'b0;
		dout_imag <= 'b0;
	end else if(din_valid_lock) begin
		dout_real <= dout_real_com;
		dout_imag <= dout_imag_com;
	end
end

endmodule
