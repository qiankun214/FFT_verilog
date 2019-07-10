vsim -voptargs="+acc" work.bu_top 

add wave -position end  sim:/bu_top/clk
add wave -position end  sim:/bu_top/rst_n

add wave -position end  sim:/bu_top/dut/din_valid
add wave -position end  sim:/bu_top/dut/din_busy
add wave -position end  sim:/bu_top/dut/din_real
add wave -position end  sim:/bu_top/dut/din_imag
add wave -position end  sim:/bu_top/dut/dout_valil
add wave -position end  sim:/bu_top/dut/dout_busy
add wave -position end  sim:/bu_top/dut/dout_real
add wave -position end  sim:/bu_top/dut/din_weight_real
add wave -position end  sim:/bu_top/dut/din_weight_imag

add wave -position end  sim:/bu_top/dut/butterfly_op1_real
add wave -position end  sim:/bu_top/dut/butterfly_op1_imag
add wave -position end  sim:/bu_top/dut/butterfly_op2_real
add wave -position end  sim:/bu_top/dut/butterfly_op2_imag

add wave -position end  sim:/bu_top/dut/weight_real
add wave -position end  sim:/bu_top/dut/weight_imag
add wave -position end  sim:/bu_top/dut/butterfly_tmp_real
add wave -position end  sim:/bu_top/dut/butterfly_tmp_imag

add wave -position end  sim:/bu_top/dut/butterfly_r1_real
add wave -position end  sim:/bu_top/dut/butterfly_r1_imag
add wave -position end  sim:/bu_top/dut/butterfly_r2_real
add wave -position end  sim:/bu_top/dut/butterfly_r2_imag