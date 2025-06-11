rm -rf build
mkdir build 2>/dev/null

ghdl -a --workdir=build ../StateMachine/state_machine.vhd 
ghdl -a --workdir=build ../ProgramCounter/program_counter.vhd
ghdl -a --workdir=build ../ProgramCounter/program_counter_manager.vhd
ghdl -a --workdir=build ../ROM/rom.vhd
ghdl -a --workdir=build ../ControlUnit/control_unit.vhd 
ghdl -a --workdir=build ../ULA/ula.vhd
ghdl -a --workdir=build ../ULA/acumulador.vhd
ghdl -a --workdir=build ../banco_reg.vhd
ghdl -a --workdir=build ../reg_16.vhd
ghdl -a --workdir=build ../InstructionRegister/instruction_register.vhd
ghdl -a --workdir=build processor.vhd
ghdl -a --workdir=build processor_tb.vhd

ghdl -e --workdir=build -o build/state_machine state_machine
ghdl -e --workdir=build -o build/program_counter program_counter
ghdl -e --workdir=build -o build/program_counter_manager program_counter_manager
ghdl -e --workdir=build -o build/rom rom
ghdl -e --workdir=build -o build/control_unit control_unit
ghdl -e --workdir=build -o build/ula ula
ghdl -e --workdir=build -o build/ula acumulador
ghdl -e --workdir=build banco_reg
ghdl -e --workdir=build reg_16
ghdl -e --workdir=build -o build/instruction_register instruction_register


ghdl -e --workdir=build -o processor processor
ghdl -e --workdir=build -o processor_tb processor_tb

ghdl -r --workdir=build processor_tb --wave=build/processor_tb.ghw
gtkwave build/processor_tb.ghw -o processor_tb_wave_config.gtkw
