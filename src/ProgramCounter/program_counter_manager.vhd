library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_manager is
    port (
        clk : in std_logic;
        rst : in std_logic;
        wr_en   : in std_logic;
        jump_en : in std_logic; 
        jump_addr: in unsigned(7 downto 0); 
        br_en   : in std_logic; -- br_enable
        br_addr : in unsigned(7 downto 0); -- br_in
        opcode : in unsigned(4 downto 0);
        beq_cond : in std_logic; -- zero flag
        blt_cond : in std_logic; -- carry flag
        bcs_cond : in std_logic; -- overflow flag
        data_out: out unsigned(7 downto 0) 
    );
end entity;

architecture a_program_counter_manager of program_counter_manager is
    component program_counter is
        port (
            clk     : in std_logic;
            rst     : in std_logic;
            wr_en   : in std_logic;
            data_in : in unsigned(7 downto 0); -- instrucao que vai ser lida
            data_out: out unsigned(7 downto 0) -- proxima instrucao
        );
    end component;

    signal wr_en_pc_s: std_logic := '0';
    signal data_out_pc_s: unsigned(7 downto 0) := (others => '0');
    signal data_in_pc_s: unsigned(7 downto 0) := (others => '0');

    signal rel_addr_s: unsigned(7 downto 0) := (others => '0');
    signal bne_cond_s : std_logic := '0';
    signal bgt_cond_s : std_logic := '0';
    signal bls_cond_s : std_logic := '0';

    signal pc_plus_s: unsigned(7 downto 0) := (others => '0');
    signal jump_addr_s: unsigned(7 downto 0) := (others => '0');

    bne_cond_s <= not beq_cond;
    bgt_cond_s <= not blt_cond;
    bls_cond_s <= beq_cond or blt_cond;

    rel_addr_s <= data_out_pc_s + br_addr;

    begin
        pc: program_counter
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_pc_s,
            data_in  => data_in_pc_s,
            data_out => data_out_pc_s
        );
        
        -- lab 5
        -- data_in_pc_s <= jump_addr when jump_en = '1' else
        --                 pc_plus_s;

        data_in_pc_s <= jump_addr when jump_en = '1' else
        rel_addr_s when (br_en = '1' and (
            (opcode = "00011" and bls_cond_s = '1') or -- BLS
            (opcode = "00100" and bcs_cond = '1') or     -- BCS
            (opcode = "00101" and beq_cond = '1') or  -- BEQ
            (opcode = "00110" and bne_cond_s = '1') or -- BNE
            (opcode = "00111" and bgt_cond_s = '1') or -- BGT
            (opcode = "01000" and blt_cond = '1')   -- BLT
        )) else
        pc_plus_s;

        wr_en_pc_s <= wr_en;

        pc_plus_s <= data_out_pc_s + 1;        
        data_out <= data_out_pc_s;
end architecture;
