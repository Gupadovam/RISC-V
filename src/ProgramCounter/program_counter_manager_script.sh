mkdir build 2>/dev/null

ghdl -a --workdir=build program_counter.vhd
ghdl -a --workdir=build program_counter_manager.vhd
ghdl -e --workdir=build -o build/program_counter_manager program_counter_manager
ghdl -e --workdir=build -o build/program_counter program_counter

ghdl -a --workdir=build program_counter_manager_tb.vhd
ghdl -e --workdir=build -o program_counter_manager_tb program_counter_manager_tb

ghdl -r --workdir=build program_counter_manager_tb --wave=build/program_counter_manager_tb.ghw
gtkwave build/program_counter_manager_tb.ghw -o program_counter_manager_config.gtkw