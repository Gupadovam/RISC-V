library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor_tb is
end entity;

architecture a_processor_tb of processor_tb is
    component processor is
        port(
            clk : in std_logic;
            rst : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';

begin
    uut: processor port map(
        clk => clk,
        rst => rst
    );

    sim_time_proc: process
    begin
        wait for 50 us;
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

    tb: process
    begin
        rst <= '1';
        wait for period_time;
        rst <= '0';
        wait for period_time;

        wait;
    end process tb;
end architecture;
