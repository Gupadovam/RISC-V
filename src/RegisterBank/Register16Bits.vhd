library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register16Bits is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0)
    );
end entity;

architecture a_reg16 of Register16Bits is
    signal reg_value : unsigned(15 downto 0) := (others => '0');

    begin
        process(clk, rst, wr_en)
            begin
            if rst = '1' then
                reg_value <= (others => '0');
            elsif rising_edge(clk) then
                if wr_en = '1' then
                    reg_value <= data_in;
                end if;
            end if;
        end process;

        data_out <= reg_value;
end architecture;