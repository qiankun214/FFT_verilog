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
wire is_dinfifo_empty;
wire is_doutfifo_full;
wire is_din = !fx2_slcs_n && !fx2_sloe_n && !fx2_slrd_n && !is_dinfifo_empty;
wire is_dout = !fx2_slcs_n && fx2_sloe_n && !fx2_slwr_n && !is_doutfifo_full;

// din fsm
localparam INIT = 2'b00;
localparam WIGH = 2'b01;
localparam DATA = 2'b11;

reg [NPOINT + NPOINT - 1:0] weight_count;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		weight_count <= 'b0;
	end else if(din_mode == WIGH && is_din) begin
		weight_count <= weight_count + 1'b1;
	end
end

reg [NPOINT:0] data_count;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		data_count <= 'b0;
	end else if(din_mode == DATA && is_din) begin
		data_count <= data_count + 1'b1;
	end
end

reg [1:0] din_mode,next_din_mode;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		din_mode <= 'b0;
	end else begin
		din_mode <= next_din_mode;
	end
end

always @ (*) begin
	case (din_mode)
		INIT:next_din_mode = WIGH;
		WIGH:begin
			if(weight_count == 2 * NPOINT * (2 ** (NPOINT - 1)) && is_din) begin
				next_din_mode = DATA;
			end else begin
				next_din_mode = WIGH;
			end
		end
		DATA:next_din_mode = DATA;
		default:next_din_mode = INIT;
	endcase
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_weight_valid <= 'b0;
	end else if(din_mode == WIGH && is_din) begin
		fft_weight_valid <= weight_count[0];
	end else begin
		fft_weight_valid <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_weight_real <= 'b0;
	end else if(din_mode == WIGH && is_din && !weight_count[0]) begin
		fft_weight_real <= fx2_db;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_weight_imag <= 'b0;
	end else if(din_mode == WIGH && is_din && weight_count[0]) begin
		fft_weight_imag <= fx2_db;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_din_real <= 'b0;
	end else if(din_mode == DATA && is_din && !data_count[0]) begin
		fft_din_real <= {fx2_db,fft_din_real[16 * (2 ** NPOINT) - 1:15]};
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_din_imag <= 'b0;
	end else if(din_mode == DATA && is_din && data_count[0]) begin
		fft_din_imag <= {fx2_db,fft_din_imag[16 * (2 ** NPOINT) - 1:15]};
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_din_valid <= 'b0;
	end else if(din_mode == DATA && is_din && data_count[0] == 2 ** (NPOINT+1)-1) begin
		fft_din_valid <= 1'b1;
	end else begin
		fft_din_valid <= 'b0;
	end
end

// dout fsm
localparam DOUT_INIT = 1'b0;
localparam DOUT_WORK = 1'b1;
reg [NPOINT:0] result_count;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		result_count <= 'b0;
	end else if(dout_mode == DOUT_WORK && is_dout) begin
		result_count <= result_count + 1'b1;
	end
end

reg dout_mode,next_dout_mode;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout_mode <= DOUT_INIT;
	end else begin
		dout_mode <= next_din_mode;
	end
end

always @ (*) begin
	case (dout_mode)
		DOUT_INIT:begin
			if(fft_dout_valid) begin
				next_dout_mode <= DOUT_WORK;
			end else begin
				next_dout_mode <= DOUT_INIT;
			end
		end
		DOUT_WORK:begin
			if(result_count == 2 ** (NPOINT+1)-1 && is_dout) begin
				next_dout_mode <= DOUT_INIT;
			end else begin
				next_dout_mode <= DOUT_WORK;
			end
		end
		default:next_dout_mode <= DOUT_INIT;
	endcase
end

// usb interface
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_slcs_n <= 1'b1;
	end else if(din_mode != INIT || dout_mode != DOUT_INIT) begin
		fx2_slcs_n <= 1'b0;
	end else begin
		fx2_slcs_n <= 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_sloe_n <= 1'b1;
	end else if(din_mode != INIT) begin
		fx2_sloe_n <= 1'b0;
	end else if(dout_mode != DOUT_INIT) begin
		fx2_sloe_n <= 1'b1;
	end
end

reg [1:0] cs_delay;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cs_delay <= 'b0;
	end else if(fx2_slcs_n && cs_delay != 2'd2) begin
		cs_delay <= cs_delay + 1'b1;
	end else if(!fx2_slcs_n) begin
		cs_delay <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_slrd_n <= 1'b1;
		fx2_slwr_n <= 1'b1;
	end else if(din_mode != INIT && cs_delay == 2'd2) begin
		fx2_slrd_n <= 1'b0;
		fx2_slwr_n <= 1'b1;
	end else if(dout_mode != DOUT_INIT && cs_delay == 2'd2) begin
		fx2_slrd_n <= 1'b1;
		fx2_slwr_n <= 1'b0;
	end else begin
		fx2_slrd_n <= 1'b1;
		fx2_slwr_n <= 1'b1;
	end
end

integer i;
reg [15:0] fx2_dout_real [2 ** NPOINT - 1:0];
reg [15:0] fx2_dout_imag [2 ** NPOINT - 1:0];
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for (int i = 0; i < 2 ** NPOINT; i = i + 1) begin
			fx2_dout_real[i] <= 'b0;
			fx2_dout_imag[i] <= 'b0;
		end
	end else if(fft_dout_valid && !fft_dout_busy) begin
		for (int i = 0; i < 2 ** NPOINT; i = i + 1) begin
			fx2_dout_real[i] <= fft_dout_real[i*16 +: 16];
			fx2_dout_imag[i] <= fft_dout_imag[i*16 +: 16];
		end
	end
end

reg [15:0] fx2_dout;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_dout <= 'b0;
	end else if(dout_mode == DOUT_WORK && fx2_sloe_n == 1'b1) begin
		if(is_dout && result_count[0] == 1'b0) begin
			fx2_dout <= fx2_dout_imag[result_count[NPOINT:1] + 1'b1];
		end else(is_dout && result_count[0] == 1'b1) begin
			fx2_dout <= fx2_dout_real[result_count[NPOINT:1] + 1'b1];
		end
	end else begin
		fx2_dout <= fx2_dout_real[0];
	end
end

assign fx2_db == (fx2_sloe_n)?fx2_dout:'bz;

endmodule
