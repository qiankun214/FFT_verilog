module usb_interface #(parameter int NPOINT = 3)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	// cy
	input fx2_flaga,
	input fx2_flagb,
	input fx2_flagc,
	input fx2_flagd,

	output reg fx2_slcs_n,
	output reg fx2_slwr_n,
	output reg fx2_slrd_n,
	output reg fx2_sloe_n,
	output reg [1:0]fx2_a,

	inout [15:0] fx2_db,

	// inter
	output reg fft_weight_valid,
	output reg [15:0]fft_weight_real,
	output reg [15:0]fft_weight_imag,

	output reg fft_din_valid,
	input fft_din_busy
	output reg [16 * (2 ** NPOINT) - 1:0] fft_din_real,
	output reg [16 * (2 ** NPOINT) - 1:0] fft_din_imag,

	input fft_dout_valid,
	output reg fft_dout_busy,
	input [16 * (2 ** NPOINT) - 1:0] fft_dout_real,
	input [16 * (2 ** NPOINT) - 1:0] fft_dout_imag
);
// usb
wire is_din;


// inter fsm
localparam INIT = 2'b00;
localparam WIGH = 2'b01;
localparam DATA = 2'b11;

reg [NPOINT + NPOINT - 1:0] weight_count;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		weight_count <= 'b0;
	end else if(inter_mode == WIGH && is_din) begin
		weight_count <= weight_count + 1'b1;
	end else begin
		weight_count <= 'b0;
	end
end

reg [1:0] inter_mode,inter_next_mode;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		inter_mode <= 'b0;
	end else begin
		inter_mode <= inter_next_mode;
	end
end

always @ (*) begin
	case (inter_mode)
		INIT:inter_next_mode = WIGH;
		WIGH:begin
			if(weight_count == 2 * NPOINT * (2 ** (NPOINT - 1))) begin
				inter_next_mode = DATA;
			end else begin
				inter_next_mode = WIGH;
			end
		end
		DATA:inter_next_mode = DATA;
		default:inter_next_mode = INIT;
	endcase
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_weight_valid <= 'b0;
	end else if(mode == WIGH && is_din) begin
		fft_weight_valid <= weight_count[0];
	end else begin
		fft_weight_valid <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_weight_real <= 'b0;
	end else if(mode == WIGH && is_din && !weight_count[0]) begin
		fft_weight_real <= fx2_db;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_weight_imag <= 'b0;
	end else if(mode == WIGH && is_din && weight_count[0]) begin
		fft_weight_imag <= fx2_db;
	end
end

endmodule
