# Main 50 MHz clock coming from the DE2/DE10 board
create_clock -name clk50 -period 20.0 [get_ports CLOCK_50]

# Asynchronous reset (SW[0])
set_false_path -from [get_ports SW[0]]

# (Optional but recommended) Mark buttons/switches as async too:
set_false_path -from [get_ports KEY[*]]
set_false_path -from [get_ports SW[*]]
