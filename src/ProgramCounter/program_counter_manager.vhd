library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_manager is
    port (
        clk : in std_logic;
        rst : in std_logic;
        wr_en   : in std_logic;
        jump_en : in std_logic; 
        jump_addr: in unsigned(6 downto 0); 
        opcode : in unsigned(6 downto 0);
        data_out: out unsigned(6 downto 0) 
    );
end entity;

architecture a_program_counter_manager of program_counter_manager is
    component program_counter is
        port (
            clk     : in std_logic;
            rst     : in std_logic;
            wr_en   : in std_logic;
            data_in : in unsigned(6 downto 0); -- instrucao que vai ser lida
            data_out: out unsigned(6 downto 0) -- proxima instrucao
        );
    end component;

    signal wr_en_pc_s: std_logic := '0';
    signal data_out_pc_s: unsigned(6 downto 0) := (others => '0');
    signal data_in_pc_s: unsigned(6 downto 0) := (others => '0');

    signal pc_plus_s: unsigned(6 downto 0) := (others => '0');
    signal jump_addr_s: unsigned(6 downto 0) := (others => '0');

    begin
        pc: program_counter
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_pc_s,
            data_in  => data_in_pc_s,
            data_out => data_out_pc_s
        );

        data_in_pc_s <= jump_addr when jump_en = '1' else
                        pc_plus_s;

        wr_en_pc_s <= wr_en;

        pc_plus_s <= data_out_pc_s + 1;        
        data_out <= data_out_pc_s;
end architecture;
