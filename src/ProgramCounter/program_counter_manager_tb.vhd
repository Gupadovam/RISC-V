library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity program_counter_manager_tb is
end entity;

architecture a_program_counter_manager of program_counter_manager_tb is
    component program_counter_manager is
        port (
            clk : in std_logic;
            rst : in std_logic;
            wr_en   : in std_logic;
            jump_en : in std_logic; 
            jump_addr: in unsigned(7 downto 0); 
            opcode : in unsigned(4 downto 0);
            data_out: out unsigned(7 downto 0) 
        );
    end component;

    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal wr_en_s : std_logic := '0';
    signal jump_en_s : std_logic := '0';
    signal jump_addr_s : unsigned(7 downto 0) := (others => '0');
    signal opcode_s : unsigned(4 downto 0) := (others => '0');
    signal data_out_s: unsigned(7 downto 0) := (others => '0');

begin
    uut: program_counter_manager port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_s,
        jump_en => jump_en_s,
        jump_addr => jump_addr_s,
        opcode => opcode_s,
        data_out => data_out_s
    );

    sim_time_proc: process
    begin
        wait for 10 us;
        finished <=  '1';
        wait;
    end process sim_time_proc;

    clk_proc: process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

    process
    begin
        wait for 100 ns;
        wr_en_s <= '1';
        wait for 100 ns;
        jump_addr_s <= "00000011";
        jump_en_s <= '1';
        wait for 100 ns;
        jump_en_s <= '0';
        wait for 100 ns;
        wr_en_s <= '1';
        jump_addr_s <= "00000010";
        wait for 100 ns;
        wr_en_s <= '0';
        wait for 100 ns;
        wait;
    end process;

end architecture;
