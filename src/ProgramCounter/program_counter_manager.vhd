library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_manager is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        wr_en       : in  std_logic;
        jump_en     : in  std_logic;
        jump_addr   : in  unsigned(9 downto 0);
        br_en       : in  std_logic;
        br_addr     : in  unsigned(9 downto 0);
        instruction : in  unsigned(13 downto 0);
        beq_cond    : in  std_logic; -- The Zero flag (Z)
        bhs_cond    : in  std_logic; -- The Carry flag (C)
        data_out    : out unsigned(9 downto 0)
    );
end entity;

architecture a_program_counter_manager of program_counter_manager is
    component program_counter is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(9 downto 0);
            data_out : out unsigned(9 downto 0)
        );
    end component;

    signal opcode        : unsigned(3 downto 0);
    signal pc_current_s  : unsigned(9 downto 0);
    signal pc_next_s     : unsigned(9 downto 0);
    signal pc_incremented_s : unsigned(9 downto 0);
    signal branch_target_s : unsigned(9 downto 0);
    signal branch_taken_s  : std_logic;

begin
    opcode <= instruction(13 downto 10);

    pc : program_counter port map(
        clk      => clk,
        rst      => rst,
        wr_en    => wr_en,
        data_in  => pc_next_s,
        data_out => pc_current_s
    );

    -- Calculate PC + 1
    pc_incremented_s <= pc_current_s + 1;
    
    -- Calculate relative branch target address
    branch_target_s <= unsigned(signed(pc_current_s) + signed(resize(br_addr, 10)));

    -- Determine if any conditional branch should be taken
    branch_taken_s <= '1' when (br_en = '1' and (
                                (opcode = "1100" and beq_cond = '0') or -- BNE (Branch if Z=0)
                                (opcode = "1101" and bhs_cond = '1') or -- BHS (Branch if C=1)
                                (opcode = "1110" and beq_cond = '1') or -- BEQ (Branch if Z=1)
                                (opcode = "1111" and bhs_cond = '0')    -- BLT (Branch if C=0)
                               )) else '0';

    -- Select the next value for the Program Counter
    pc_next_s <= jump_addr       when jump_en = '1' else
                 branch_target_s when branch_taken_s = '1' else
                 pc_incremented_s;

    -- Output the current PC value to fetch from ROM
    data_out <= pc_current_s;

end architecture;