vsim -voptargs=+acc work.tb_usb_interface

add wave -position end  sim:/tb_usb_interface/clk
add wave -position end  sim:/tb_usb_interface/rst_n
add wave -position end  sim:/tb_usb_interface/fx2_flaga
add wave -position end  sim:/tb_usb_interface/fx2_flagb
add wave -position end  sim:/tb_usb_interface/fx2_flagc
add wave -position end  sim:/tb_usb_interface/fx2_flagd
add wave -position end  sim:/tb_usb_interface/fx2_slcs_n
add wave -position end  sim:/tb_usb_interface/fx2_slwr_n
add wave -position end  sim:/tb_usb_interface/fx2_slrd_n
add wave -position end  sim:/tb_usb_interface/fx2_sloe_n
add wave -position end  sim:/tb_usb_interface/dut/fx2_pktend_n
add wave -position end  sim:/tb_usb_interface/dut/fx2_a
add wave -position end  sim:/tb_usb_interface/dut/fx2_db
add wave -position end  sim:/tb_usb_interface/dut/fft_weight_valid
add wave -position end  sim:/tb_usb_interface/dut/fft_weight_real
add wave -position end  sim:/tb_usb_interface/dut/fft_weight_imag
add wave -position end  sim:/tb_usb_interface/dut/fft_din_valid
add wave -position end  sim:/tb_usb_interface/dut/fft_din_busy
add wave -position end  sim:/tb_usb_interface/dut/fft_din_real
add wave -position end  sim:/tb_usb_interface/dut/fft_din_imag
add wave -position end  sim:/tb_usb_interface/dut/fft_dout_valid
add wave -position end  sim:/tb_usb_interface/dut/fft_dout_busy
add wave -position end  sim:/tb_usb_interface/dut/fft_dout_real
add wave -position end  sim:/tb_usb_interface/dut/fft_dout_imag

add wave -position end  sim:/tb_usb_interface/dut/mode
add wave -position end  sim:/tb_usb_interface/dut/next_mode