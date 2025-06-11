library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_register is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(13 downto 0);
        data_out : out unsigned(13 downto 0)
    );
end entity;

architecture a_instruction_register of instruction_register is
    signal reg : unsigned(13 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' then
                reg <= data_in;
            end if;
        end if;
    end process;
    
    data_out <= reg;
end architecture;