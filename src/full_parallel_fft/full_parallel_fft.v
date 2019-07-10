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

	// output
	output reg dout_valil,
	output reg dout_busy,

	output reg [WIDTH * (2 ** NPOINT) - 1:0] dout_real,
	output reg [WIDTH * (2 ** NPOINT) - 1:0] dout_imag,

	input din_weight_valid,
	input [WIDTH - 1:0] din_weight_real,
	input [WIDTH - 1:0] din_weight_imag
);

wire [NPOINT * (2 ** (NPOINT - 1)) * WIDTH - 1:0]weight_real;
wire [NPOINT * (2 ** (NPOINT - 1)) * WIDTH - 1:0]weight_imag;
weight_buffer #(
	.NPOINT 	(NPOINT),
	.WIDTH		(WIDTH)
) u_weight_buffer (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low
	
	.din_weight_valid(din_weight_valid),
	.din_weight_real(din_weight_real),
	.din_weight_imag(din_weight_imag),

	.weight_real(weight_real),
	.weight_imag(weight_imag)
);

localparam WEIG_WIDTH = WIDTH * (2 ** (NPOINT - 1));
localparam TEMP_WIDTH = WIDTH * (2 ** NPOINT);
genvar i;

logic 					   	pe_din_valid 	[ NPOINT - 1:0 ];
logic 					   	pe_din_busy 	[ NPOINT - 1:0 ];
logic [ TEMP_WIDTH - 1:0 ] 	pe_din_real 	[ NPOINT - 1:0 ];
logic [ TEMP_WIDTH - 1:0 ] 	pe_din_imag 	[ NPOINT - 1:0 ];

logic 					   	pe_dout_valid 	[ NPOINT - 1:0 ];
logic 					   	pe_dout_busy 	[ NPOINT - 1:0 ];
logic [ TEMP_WIDTH - 1:0 ] 	pe_dout_real 	[ NPOINT - 1:0 ];
logic [ TEMP_WIDTH - 1:0 ] 	pe_dout_imag 	[ NPOINT - 1:0 ];
generate
	for (i = 0; i < NPOINT; i = i + 1) begin:butterfly_unit

		// din port
		if(i == 0) begin
			assign pe_din_valid[i] 	= 	din_valid 			;
			assign din_busy 		= 	pe_din_busy[i]		;
			assign pe_din_real[i]	=	din_real 			;
			assign pe_din_imag[i] 	=	din_imag 			;
		end else begin
			assign pe_din_valid[i] 	=	pe_dout_valid[i-1]	;
			assign pe_dout_busy[i-1]=	pe_din_busy[i]		;
			assign pe_din_real[i]	=	pe_dout_real[i-1]	;
			assign pe_din_busy[i]	=	pe_dout_imag[i-1]	;
		end

		butterfly#(
			.WIDTH 	(WIDTH),
			.NPOINT (NPOINT),
			.STEP   (i)
		) u_pe (
			.clk(clk),    // Clock
			.rst_n(rst_n),  // Asynchronous reset active low

			// input
			.din_valid(pe_din_valid[i]),
			.din_busy(pe_din_busy[i]),

			.din_real(pe_din_real[i]),
			.din_imag(pe_din_imag[i]),

			// output
			.dout_valil(pe_dout_valid[i]),
			.dout_busy(pe_dout_busy[i]),

			.dout_real(pe_dout_real[i]),
			.dout_imag(pe_dout_imag[i]),

			// weight
			.din_weight_real(din_weight_real[ i * WEIG_WIDTH +: WEIG_WIDTH ]),
			.din_weight_imag(din_weight_imag[ i * WEIG_WIDTH +: WEIG_WIDTH ])
		);
	end
endgenerate

assign dout_valil = pe_dout_valid[ NPOINT - 1 ];
assign pe_dout_busy[ NPOINT - 1] = dout_busy;
assign dout_real = pe_dout_real[ NPOINT - 1 ];
assign dout_imag = pe_dout_imag[ NPOINT - 1 ];

endmodule