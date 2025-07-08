library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        wr_en    : in  std_logic;
        data_in  : in  unsigned(9 downto 0); 
        data_out : out unsigned(9 downto 0) 
    );
end entity;

architecture a_program_counter of program_counter is
    signal data : unsigned(9 downto 0) := (others => '0'); 
begin
    process(clk, rst) -- Removed wr_en from sensitivity list, as it's checked inside rising_edge
    begin
        if rst = '1' then
            data <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' then
                data <= data_in;
            end if;
        end if;
    end process;

    data_out <= data;
end architecture;
