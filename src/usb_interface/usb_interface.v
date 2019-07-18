module usb_interface #(parameter NPOINT = 3)(
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
	output reg fx2_pktend_n,
	output reg [1:0]fx2_a,

	inout [15:0] fx2_db,

	// inter
	output reg fft_weight_valid,
	output reg [15:0]fft_weight_real,
	output reg [15:0]fft_weight_imag,

	output reg fft_din_valid,
	input fft_din_busy,
	output reg [16 * (2 ** NPOINT) - 1:0] fft_din_real,
	output reg [16 * (2 ** NPOINT) - 1:0] fft_din_imag,

	input fft_dout_valid,
	output fft_dout_busy,
	input [16 * (2 ** NPOINT) - 1:0] fft_dout_real,
	input [16 * (2 ** NPOINT) - 1:0] fft_dout_imag
);
// fx2 data
wire is_fx2_din;
wire is_fx2_dout;

wire is_fx2_din_noempty;

// fft
wire is_fft_din = fft_din_valid && !fft_din_busy;
wire is_fft_dout = fft_dout_valid && !fft_dout_busy;


// fsm
reg [ 2:0 ] mode,next_mode;
localparam REST = 3'd000;
localparam WEIG = 3'd001;
localparam INIT = 3'd011;
localparam DIND = 3'd010;
localparam DOUT = 3'd111;

reg [ NPOINT + NPOINT - 1:0 ] weight_counte;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		weight_counte <= 'b0;
	end else if(mode == WEIG && is_fx2_din) begin
		weight_counte <= weight_counte + 1'b1;
	end
end

reg [ NPOINT - 1:0 ] din_counte;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		din_counte <= 'b0;
	end else if(mode == DIND && is_fx2_din) begin
		din_counte <= din_counte + 1'b1;
	end else if(mode == INIT) begin
		din_counte <= 'b0;
	end
end

reg [ NPOINT - 1:0 ] dout_counte;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout_counte <= 'b0;
	end else if(mode == DOUT && is_fx2_dout) begin
		dout_counte <= dout_counte + 1'b1;
	end else if(mode == INIT) begin
		dout_counte <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mode <= REST;
	end else begin
		mode <= next_mode;
	end
end

localparam WEIGHT_NUM = NPOINT * (2 ** (NPOINT - 1)) - 1;
localparam TRAN_NUM = 2 ** NPOINT - 1;
always @ (*) begin
	case (mode)
		REST:next_mode = WEIG;
		WEIG:begin
			if(weight_counte == WEIGHT_NUM && is_fx2_din) begin
				next_mode = INIT;
			end else begin
				next_mode = WEIG;
			end
		end
		INIT:begin
			if(is_fft_dout) begin
				next_mode = DOUT;
			end else if(is_fx2_din_noempty) begin
				next_mode = DIND;
			end else begin
				next_mode = INIT;
			end
		end
		DIND:begin
			if(din_counte == TRAN_NUM && is_fx2_din) begin
				next_mode = INIT;
			end else begin
				next_mode = DIND;
			end
		end
		DOUT:begin
			if(dout_counte == TRAN_NUM && is_fx2_dout) begin
				next_mode = INIT;
			end else begin
				next_mode = DOUT;
			end
		end
		default:next_mode = REST;
	endcase
end

	// output reg fx2_slcs_n,
	// output reg fx2_slwr_n,
	// output reg fx2_slrd_n,
	// output reg fx2_sloe_n,
	// output reg fx2_pktend,
	// output reg [1:0]fx2_a,

	// inout [15:0] fx2_db,

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_slcs_n <= 1'b1;
	end else if(next_mode != REST && next_mode != INIT) begin
		fx2_slcs_n <= 1'b0;
	end else begin
		fx2_slcs_n <= 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_sloe_n <= 1'b1;
	end else if(next_mode == DOUT) begin
		fx2_sloe_n <= 1'b0;
	end else begin
		fx2_sloe_n <= 1'b1;
	end
end

reg [ 1:0 ] delay_counte;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		delay_counte <= 'b0
	end else if(mode == DOUT || mode == DIND) begin
		if(delay_counte != 2'd3) begin
			delay_counte <= delay_counte + 1'd1;
		end
	end else begin
		delay_counte <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_slrd_n <= 1'b1;
		fx2_slwr_n <= 1'b1;
		fx2_a <= 'b0
	end else if(mode == DIND && delay_counte == 2'd3) begin
		fx2_slrd_n <= 1'b0;
		fx2_slwr_n <= 1'b1;
		fx2_a <= 2'b0;
	end else if(mode == DOUT && delay_counte == 2'd3) begin
		fx2_slrd_n <= 1'b1;
		fx2_slwr_n <= 1'b0;
		fx2_a <= 2'b10;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fx2_pktend_n <= 1'b1;
	end else if(din_counte == TRAN_NUM) begin
		fx2_pktend_n <= 1'b0;
	end else if(dout_counte == TRAN_NUM) begin
		fx2_pktend_n <= 1'b0;
	end else begin
		fx2_pktend_n <= 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		fft_weight_real	 <= 'b0;
		fft_weight_imag	 <= 'b0;
		fft_weight_valid <= 'b0;
	end else if(mode == WEIG && is_fx2_din) begin
		if(weight_counte[0] == 1'b0) begin
			fft_weight_real <= fx2_db;
		end else begin
			fft_weight_imag <= fx2_db;
		end
		fft_weight_valid <= 1'b1;
	end else begin
		fft_weight_valid <= 1'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_din_real <= 'b0;
		fft_din_imag <= 'b0;
	end else if(mode == DIND && is_fx2_din) begin
		if(din_counte[0]) begin
			fft_din_imag[din_counte[NPOINT - 1:1] * 16 +: 16] <= fx2_db;
		end else begin
			fft_din_real[din_counte[NPOINT-1:1] * 16 +: 16] <= fx2_db;
		end
	end
end
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fft_din_valid <= 'b0;
	end else if(mode == DIND && next_mode == INIT) begin
		fft_din_valid <= 1'b1;
	end else if(is_fft_din)begin
		fft_din_valid <= 1'b0;
	end
end

reg [ NPOINT * 16 - 1:0 ] tmp_dout_real;
reg [ NPOINT * 16 - 1:0 ] tmp_dout_imag;
always @ (posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		fft_dout_busy <= 'b0;
	end else if(is_fft_dout) begin
		fft_dout_busy <= 1'b1; 
	end else if(mode == DOUT && next_mode == INIT) begin
		fft_dout_busy <= 'b0;
	end
end
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		tmp_dout_real <= 'b0;
		tmp_dout_imag <= 'b0;
	end else if(is_fft_dout) begin
		tmp_dout_real <= fft_dout_real;
		tmp_dout_imag <= fft_dout_imag;
	end else if(mode == DOUT && is_fft_dout && dout_counte[0]) begin
		tmp_dout_real <= {16'd0,tmp_dout_real[NPOINT * 16 - 1:16]};
		tmp_dout_imag <= {16'd0,tmp_dout_imag[NPOINT * 16 - 1:16]};
	end
end
assign fx2_db = (mode == DOUT)? (dout_counte[0])?tmp_dout_imag[15:0]:tmp_dout_real[15:0] :'bz;

endmodule
