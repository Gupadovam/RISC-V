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
		  -- LOAD: CARREGA O VALOR DO REGISTRADOR NO ACUMULADOR ACC = RX
		  -- STORE: ARMAZENA O VALOR DO ACUMULADOR NO REGISTRADOR RX = ACC
		--A. Carrega R3 (o registrador 3) com o valor 5 
      0  => B"00110_000_101_011", -- LDI R3, 5 <--- vai virar 2 instruoes : 
		-- LDI 5 (vai pro acc)
		-- STORE R3

		--B. Carrega R4 com 8 
      1  => B"00110_001_000_100", -- LDI R4, 8
		-- LDI 8 (vai pro acc)
		-- STORE R4

		--C. Soma R3 com R4 e guarda em R5 -> (2 INSTRUCOES)
      2  => B"00001_000_011_100", -- ADD R4, R4, R3
      3  => B"00101_000_100_101", -- MOV R5, R4
		-- LOAD R3 (acc pega o valor que ta no R3)
		-- ADD R4 (acc vai pegar o resultado da soma)
		-- STORE R5 (armazena em R5)

		--D. Subtrai 1 de R5
      4  => B"00011_000_001_101", -- SUBBI R5, R5, 1
		-- LOAD R5 (pega o valor de R5 e joga pro acc)
		-- SUBBI 1 (subtrai 1 do acc)
		-- STORE R5 (joga valor do acc para o r5)

		--E. Salta para o endereço 20
      5  => B"00100_0_0001_0100", -- JUMP 20
		-- mantem o mesmo

		--F. Zera R5 (nunca será executada)
      6  => B"00110_000_000_101", -- LDI R5, 0
		-- LDI 0
		-- STORE R5

		7 => B"00000_0_0000_0000", -- NOP
		8 => B"00000_0_0000_0000", -- NOP
		9 => B"00000_0_0000_0000", -- NOP
		10 => B"00000_0_0000_0000", -- NOP
		11 => B"00000_0_0000_0000", -- NOP
		12 => B"00000_0_0000_0000", -- NOP
		13 => B"00000_0_0000_0000", -- NOP
		14 => B"00000_0_0000_0000", -- NOP
		15 => B"00000_0_0000_0000", -- NOP
		16 => B"00000_0_0000_0000", -- NOP
		17 => B"00000_0_0000_0000", -- NOP
		18 => B"00000_0_0000_0000", -- NOP
		19 => B"00000_0_0000_0000", -- NOP

		--G. No endereço 20, copia R5 para R3
		20 => B"00101_000_101_011", -- MOV R3, R5
		-- LOAD R5
		-- STORE R3

		--H. Salta para o passo C desta lista (R5 <= R3+R4)
		21 => B"00101_0_0000_0010", -- JUMP 2
		-- manteo o mesmo

		--I. Zera R3 (nunca será executada)
      22 => B"00110_000_000_011", -- LDI R3, 0
		-- LDI 0
		-- STORE R3
		
		
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
