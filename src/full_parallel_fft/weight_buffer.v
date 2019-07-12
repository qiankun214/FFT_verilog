module weight_buffer #(
	parameter NPOINT = 3,
	parameter WIDTH = 16
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	input din_weight_valid,
	input [WIDTH - 1:0]din_weight_real,
	input [WIDTH - 1:0]din_weight_imag,

	output reg [NPOINT * (2 ** (NPOINT - 1)) * WIDTH - 1:0]weight_real,
	output reg [NPOINT * (2 ** (NPOINT - 1)) * WIDTH - 1:0]weight_imag
);

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		weight_real <= 'b0;
		weight_imag <= 'b0;
	end else if(din_weight_valid) begin
		weight_real <= {weight_real[NPOINT * (2 ** (NPOINT - 1)) * WIDTH - WIDTH - 1:0],din_weight_real};
		weight_imag <= {weight_imag[NPOINT * (2 ** (NPOINT - 1)) * WIDTH - WIDTH - 1:0],din_weight_imag};
	end
end

endmodule