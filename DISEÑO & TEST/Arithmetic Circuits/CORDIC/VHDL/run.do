restart -f

add wave -color gold -position end  sim:/cordic_tb/clk
add wave -position end  sim:/cordic_tb/rst
add wave -position end  sim:/cordic_tb/mode_i
add wave -position end  sim:/cordic_tb/enable_i

add wave -divider "DATA INPUTS"
add wave -color blue -decimal -position end  sim:/cordic_tb/x_i
add wave -color blue -decimal -position end  sim:/cordic_tb/y_i
add wave -color blue -decimal -position end  sim:/cordic_tb/z_i

add wave -divider "DATA OUTPUTS"
add wave -color orange -decimal -position end  sim:/cordic_tb/x_o
add wave -color orange -decimal -position end  sim:/cordic_tb/y_o
add wave -color orange -decimal -position end  sim:/cordic_tb/z_o

add wave -divider
add wave -position end  sim:/cordic_tb/enable_o
add wave -position end  sim:/cordic_tb/mode_o











run 10 us