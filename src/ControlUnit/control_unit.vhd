library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
        clk : in std_logic;
        instruction : in unsigned(13 downto 0);
        jump_en : out std_logic;
        jump_addr : out unsigned(6 downto 0)
    );
end entity;

architecture a_control_unit of control_unit is
    signal opcode : unsigned(6 downto 0) := (others => '0');

    begin
        opcode <= instruction(13 downto 7);

        jump_en <= '1' when opcode = "1000000" else '0';
        jump_addr <= instruction(6 downto 0);
end architecture;