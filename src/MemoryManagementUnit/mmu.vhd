library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mmu is
   port(
      ram_read_en  : in std_logic;
      ram_write_en : in std_logic;
      endereco_in  : in unsigned(15 downto 0);
      endereco_out : out unsigned(15 downto 0);
      exception    : out std_logic 
   );
end entity;

architecture a_mmu of mmu is
    begin
    endereco_out <= endereco_in when (to_integer(unsigned(endereco_in)) <= 127) 
                    else "0000000000000000";
    exception <= '1' when ((ram_read_en = '1' or ram_write_en = '1') and to_integer(unsigned(endereco_in)) > 127)
                else '0';
end architecture;