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

---

## This instruction set is designed for a 14-bit, 5-register, accumulator-based processor, updated to match all mandatory requirements.

### Instruction Table

- **Jumps:** Unconditional `JUMP` is absolute. Conditional branches (`BNE`, `BHS`) are relative, using the 10-bit field as a signed offset.

| Opcode | Function | Instruction Format | Explanation |
| :--- | :--- | :--- | :--- |
| **Data Transfer** |
| `0001` | `ldi Rd, imm` | `OOOO_DDD_IIIIIII` | `Reg[DDD] = IIIIIII` (Loads 7-bit immediate into a register) |
| `0010` | `load [Ra]` | `OOOO_AAA_XXXXXXX` | `ACC = MEM[Reg[AAA]]` (Loads ACC from address in register `Ra`) |
| `0011` | `store [Ra]`| `OOOO_AAA_XXXXXXX` | `MEM[Reg[AAA]] = ACC` (Stores ACC to address in register `Ra`) |
| `0100` | `mov_to_acc Rs` | `OOOO_SSS_XXXXXXX` | `ACC = Reg[SSS]` (Moves a register's value to the ACC) |
| `0101` | `mov_from_acc Rd`| `OOOO_DDD_XXXXXXX` | `Reg[DDD] = ACC` (Moves the ACC's value to a register) |
| **Arithmetic** |
| `0110` | `add Rs` | `OOOO_SSS_XXXXXXX` | `ACC = ACC + Reg[SSS]` |
| `0111` | `subb Rs` | `OOOO_SSS_XXXXXXX` | `ACC = ACC - Reg[SSS] - CarryFlag` (Subtract with Borrow) |
| `1000` | `subi imm` | `OOOO_IIIIIIIIII` | `ACC = ACC - IIIIIIIIII` (Subtract 10-bit immediate) |
| **Logic & Control** |
| `1001` | `cmpr Rs` | `OOOO_SSS_XXXXXXX` | Compares `ACC` with `Reg[SSS]` and sets processor flags. |
| `1010` | `cmpi imm` | `OOOO_IIIIIIIIII` | Compares `ACC` with a 10-bit immediate and sets flags. |
| `1011` | `jump addr` | `OOOO_AAAAAAAAAA` | `PC = AAAAAAAAAA` (**Absolute** Jump) |
| `1100` | `bne offset` | `OOOO_AAAAAAAAAA` | `PC = PC + offset` if Not Equal (**Relative** Branch) |
| `1101` | `bhs offset` | `OOOO_AAAAAAAAAA` | `PC = PC + offset` if Higher or Same (**Relative** Branch) |
| **Misc** |
| `0000` | `nop` | `OOOO_XXXXXXXXXX` | No Operation. |




> S: Source Reg<br>
> D: Destiny Reg<br>
> I: Immediate<br>
> X: Nothing<br>
> A: Address<br>
