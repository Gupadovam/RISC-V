mkdir build 2>/dev/null

ghdl -a --workdir=build state_machine.vhd
ghdl -e --workdir=build -o build/state_machine state_machine

ghdl -a --workdir=build state_machine_tb.vhd
ghdl -e --workdir=build -o state_machine_tb state_machine_tb

ghdl -r --workdir=build state_machine_tb --wave=build/state_machine_tb.ghw
gtkwave build/state_machine_tb.ghw -o state_machine_tb_wave_config.gtkw