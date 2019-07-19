vsim -voptargs=+acc work.tb_fpga_fft_acc

add wave -position end  sim:/tb_fpga_fft_acc/NPOINT
add wave -position end  sim:/tb_fpga_fft_acc/clk
add wave -position end  sim:/tb_fpga_fft_acc/rst_n
add wave -position end  sim:/tb_fpga_fft_acc/fx2_flaga
add wave -position end  sim:/tb_fpga_fft_acc/fx2_flagb
add wave -position end  sim:/tb_fpga_fft_acc/fx2_flagc
add wave -position end  sim:/tb_fpga_fft_acc/fx2_flagd
add wave -position end  sim:/tb_fpga_fft_acc/fx2_slcs_n
add wave -position end  sim:/tb_fpga_fft_acc/fx2_slwr_n
add wave -position end  sim:/tb_fpga_fft_acc/fx2_slrd_n
add wave -position end  sim:/tb_fpga_fft_acc/fx2_sloe_n
add wave -position end  sim:/tb_fpga_fft_acc/fx2_pktend_n
add wave -position end  sim:/tb_fpga_fft_acc/fx2_a
add wave -position end  sim:/tb_fpga_fft_acc/fx2_db
add wave -position end  sim:/tb_fpga_fft_acc/fx2_db_din

add wave -position end  sim:/tb_fpga_fft_acc/dut/u_fft/u_weight_buffer/weight_real
add wave -position end  sim:/tb_fpga_fft_acc/dut/u_fft/u_weight_buffer/weight_imag
add wave -position end  sim:/tb_fpga_fft_acc/dut/u_usb_if/mode