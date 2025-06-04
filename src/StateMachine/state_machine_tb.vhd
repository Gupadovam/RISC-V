library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_machine_tb is
end entity;

architecture a_state_machine_tb of state_machine_tb is
    component state_machine is
        port (
            clk : in std_logic;
            rst : in std_logic;
            estado    : out unsigned(1 downto 0)
        );
    end component;

    constant period_time : time := 100 ns;
    signal clk, rst, finished : std_logic := '0';
    signal estado : unsigned(1 downto 0);

    begin
        uut: state_machine port map (
            clk => clk,
            rst => rst,
            estado => estado
        );

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
            rst <= '1';
            wait for 50 ns;
            rst <= '0';
            wait for 50 ns;
            rst <= '1';
            wait for 200 ns;
            rst <= '0';
            wait;
        end process;
end architecture;
