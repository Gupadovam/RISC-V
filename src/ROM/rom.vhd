library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port(
      clk : in std_logic;
      endereco : in unsigned(6 downto 0);
      dado : out unsigned(13 downto 0) 
   );
end entity;

architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(13 downto 0);
   constant conteudo_rom : mem := (
      -- caso endereco => conteudo
      -- "-----.-----.----"
      -- NOP: B"XXXXX_XXXXX_XXXX"
      -- JUMP: B"OOOOOOO_AAAAAAA"
      -- A: Address
      -- O: Opcode
      0  => B"00000_00000_0000", -- NOP
      1  => B"1000000_0000011", -- JUMP to 3
      2  => B"1000000_0000100", -- JUMP to 4
      3  => B"1000000_0000010", -- JUMP to 2
      4  => B"00000_00000_0000", -- NOP
      5  => B"00000_00000_0000", -- NOP
      -- abaixo: casos omissos => (zero em todos os bits)
      others => (others=>'0')
   );

begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;