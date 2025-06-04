library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port(
        clk : in std_logic;
        rst : in std_logic
    );
end entity;

architecture a_processor of processor is
    component state_machine is
        port(
            clk : in std_logic;
            rst : in std_logic;
            estado : out unsigned(1 downto 0)
        );
    end component;

    component program_counter_manager is
        port(
            clk : in std_logic;
            rst : in std_logic;
            wr_en   : in std_logic;
            jump_en : in std_logic; 
            jump_addr: in unsigned(7 downto 0); 
            opcode : in unsigned(4 downto 0);
            data_out: out unsigned(7 downto 0) -- TODO
        );
    end component;

    component rom is
        port(
            clk : in std_logic;
            endereco : in unsigned(7 downto 0);
            dado : out unsigned(13 downto 0) 
        );
    end component;

    component control_unit is
        port(
            clk : in std_logic;
            instruction : in unsigned(13 downto 0);
            jump_en : out std_logic;
            jump_addr : out unsigned(7 downto 0)
        );
    end component;

    -- opcode
    signal opcode_s : unsigned(4 downto 0) := (others => '0');

    -- state machine
    signal estado_s : unsigned(1 downto 0) := (others => '0');

    -- pc
    signal pc_wr_en_s : std_logic := '0';
    signal pc_data_out_s : unsigned(7 downto 0) := (others => '0');

    -- rom
    signal rom_data_out_s : unsigned(13 downto 0) := (others => '0');

    -- control unit
    signal jump_en_s : std_logic := '0';
    signal jump_addr_s : unsigned(7 downto 0) := (others => '0');

    begin
        sm: state_machine
        port map(
            clk => clk,
            rst => rst,
            estado => estado_s
        );

        pc: program_counter_manager
        port map(
            clk => clk,
            rst => rst,
            wr_en => pc_wr_en_s,
            jump_en => jump_en_s, 
            jump_addr => jump_addr_s, 
            opcode => opcode_s,
            data_out => pc_data_out_s 
        );

        rom1: rom
        port map(
            clk => clk,
            endereco => pc_data_out_s,
            dado => rom_data_out_s
        );

        cu: control_unit
        port map(
            clk => clk,
            instruction => rom_data_out_s,
            jump_en => jump_en_s,
            jump_addr => jump_addr_s
        );

        -- estado 0 (fetch)
        pc_wr_en_s <= '1' when estado_s = "00" else '0';

        -- estado 1 (decode/execute)
end architecture;

