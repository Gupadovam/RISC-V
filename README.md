## How to Run the Simulation

1.  Navigate to the project directory.
2.  Make the simulation script executable (replace `run_simulation.sh` with your actual script name if different):
    ```bash
    chmod +x run_simulation.sh
    ```
3.  Execute the script:
    ```bash
    ./run_simulation.sh
    ```

The script will typically:
    - Compile all necessary VHDL files (from `src/` and `tb/` directories).
    - Run the simulation (e.g., executing the `processor_tb.vhd` testbench).
    - Generate a `.vcd` waveform file (e.g., `waveform.vcd`) in the project root or a `waveforms/` directory.
    - Open the generated `.vcd` file in GTKWave. If a `.gtkw` save file (e.g., `default_view.gtkw`) is present and configured in the script, it may load a pre-defined signal view. Otherwise, you'll need to add signals manually in GTKWave.

| Opcode |     Função    | Instrução 
|--------|---------------| --------- |
|  00000  |    nop       | OOOOO_X_XXXX_XXXX
|  00001  |    add       | OOOOO_XXX_XXX_SSS
|  00010  |    subb      | OOOOO_XXX_XXX_SSS
|  00011  |    subbi     | OOOOO_CCC_CCC_CCC  
|  00100  |    jump      | OOOOO_X_AAAA_AAAA
|  00101  |    mov       | OOOOO_XXX_SSS_DDD
|  00110  |    ldi       | OOOOO_CCC_CCC_CCC
|  00111  |    load      | OOOOO_XXX_XXX_SSS
|  01000  |    store     | OOOOO_XXX_XXX_DDD




> S: Source Reg
> D: Destiny Reg
> C: Cte
> X: nada
> A: Address
