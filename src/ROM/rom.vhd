library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port(
      clk : in std_logic;
      endereco : in unsigned(7 downto 0);
      dado : out unsigned(13 downto 0) 
   );
end entity;

architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(13 downto 0);
   constant conteudo_rom : mem := (
	-- precisa zerar acc
	-- problema de sincronia pra desativar o acc
	
   -- A. Carrega R3 com o valor 5 (LDI + STORE)
      0 => B"00110_000_000_101", -- LDI 5
      1 => B"01000_000_000_010", -- STORE ACC -> R3

   -- B. Carrega R4 com o valor 8 (LDI + STORE)
      2 => B"00110_000_001_000", -- LDI 8
      3 => B"01000_000_000_011", -- STORE ACC -> R4

   -- C. Soma R3 com R4 e guarda em R5 (LOAD R3 + ADD R4 + STORE R5)
      4 => B"00111_000_000_010", -- LOAD R3 -> ACC
      5 => B"00001_000_000_011", -- ADD ACC, ACC, R4
      6 => B"01000_000_000_100", -- STORE ACC -> R5

   -- D. Subtrai 1 de R5 (LOAD R5 + SUBBI 1 + STORE R5)
      7 => B"00111_000_000_100", -- LOAD R5 -> ACC
      8 => B"00011_000_000_001", -- SUBBI ACC, ACC, 1
      9 => B"01000_000_000_100", -- STORE ACC -> R5

   -- E. Salta para o endereço 20
     10 => B"00100_0_0001_0100", -- JUMP 20

   -- F. Zera R5 (não será executado)
     11 => B"00110_000_000_000", -- LDI 0
     12 => B"01000_000_000_100", -- STORE ACC -> R5

   -- NOPs
     13 => B"00000_0_0000_0000",
     14 => B"00000_0_0000_0000",
     15 => B"00000_0_0000_0000",
     16 => B"00000_0_0000_0000",
     17 => B"00000_0_0000_0000",
     18 => B"00000_0_0000_0000",
     19 => B"00000_0_0000_0000",

   -- G. Copia R5 para R3 (LOAD R5 + STORE R3)
     20 => B"00111_000_000_100", -- LOAD R5 -> ACC
     21 => B"01000_000_000_010", -- STORE ACC -> R3

   -- H. Salta para o passo C (endereço 4)
     22 => B"00100_0_0000_0100", -- JUMP 4

   -- I. Zera R3 (não será executado)
     23 => B"00110_000_000_000", -- LDI 0
     24 => B"01000_000_000_010", -- STORE ACC -> R3

     others => (others => '0')
   );

begin
   process(clk)
   begin
      if rising_edge(clk) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;
