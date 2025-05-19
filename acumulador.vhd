library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity acumulador is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0)
    );
end entity;

architecture a_acumulador of acumulador is
    signal reg_a : unsigned(15 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg_a <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' then
                reg_a <= data_in;
            end if;
        end if;
    end process;

    data_out <= reg_a;
end architecture;
