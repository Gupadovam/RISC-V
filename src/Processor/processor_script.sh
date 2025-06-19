#!/bin/bash

rm -rf build
mkdir build 2>/dev/null

ghdl -a --workdir=build ../StateMachine/state_machine.vhd
ghdl -a --workdir=build ../ProgramCounter/program_counter.vhd
ghdl -a --workdir=build ../ProgramCounter/program_counter_manager.vhd
ghdl -a --workdir=build ../ROM/rom.vhd
ghdl -a --workdir=build ../RAM/ram.vhd
ghdl -a --workdir=build ../ControlUnit/control_unit.vhd
ghdl -a --workdir=build ../ULA/ula.vhd
ghdl -a --workdir=build ../Register1Bit/Register1bit.vhd
ghdl -a --workdir=build ../RegisterBank/Register16Bits.vhd
ghdl -a --workdir=build ../RegisterBank/RegisterBank.vhd
ghdl -a --workdir=build ../MemoryManagementUnit/mmu.vhd
ghdl -a --workdir=build processor.vhd
ghdl -a --workdir=build processor_tb.vhd

ghdl --elab-run --workdir=build processor_tb --wave=build/processor_tb.ghw

gtkwave build/processor_tb.ghw --save=processor_tb_wave_config.gtkw