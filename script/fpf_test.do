vsim -voptargs="+acc" work.fpf_top 

add wave -position end  sim:/fpf_top/clk
add wave -position end  sim:/fpf_top/rst_n

add wave -position end  sim:/fpf_top/dut/din_valid
add wave -position end  sim:/fpf_top/dut/din_busy
add wave -position end  sim:/fpf_top/dut/din_real
add wave -position end  sim:/fpf_top/dut/din_imag
add wave -position end  sim:/fpf_top/dut/dout_valil
add wave -position end  sim:/fpf_top/dut/dout_busy
add wave -position end  sim:/fpf_top/dut/dout_real


add wave -position end  sim:/fpf_top/dut/din_weight_valid
add wave -position end  sim:/fpf_top/dut/din_weight_real
add wave -position end  sim:/fpf_top/dut/din_weight_imag
