library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
		  clk : in std_logic;
		  instruction : in unsigned(13 downto 0);
		  reg_wr_en : out std_logic;
		  sel_op_ula : out std_logic_vector(1 downto 0);
		  source_reg : out unsigned(2 downto 0);
		  destiny_reg : out unsigned(2 downto 0);
		  jump_en : out std_logic;
		  jump_addr : out unsigned(7 downto 0);
		  acc_en : out std_logic;
		  immediate : out unsigned(8 downto 0);
		  sel_ula_src : out std_logic;
		  sel_acc_src : out std_logic;
		  borrow_in : out std_logic
    );
end entity;

architecture a_control_unit of control_unit is
    signal opcode : unsigned(4 downto 0);
begin

	-- Extrai o opcode
	opcode <= instruction(13 downto 9);

	-- Immediate: SUBBI e LDI
	immediate <= instruction(8 downto 0) when (opcode = "00011" or opcode = "00110") else (others => '0');

	-- Sinal de pulo
	jump_en   <= '1' when opcode = "00100" else '0';
	jump_addr <= instruction(7 downto 0);

	-- Seleção da operação da ULA
	sel_op_ula <= "00" when opcode = "00001" else -- ADD
			"01" when opcode = "00010" else -- SUBB
			"11" when opcode = "00011" else -- SUBBI
			"10"; -- padrão (nao faz nada)

	-- Ativa escrita no acumulador (único destino em ADD, SUBB, etc.)
	acc_en <= '1' when (opcode = "00001" or  -- ADD
				opcode = "00010" or  -- SUBB
				opcode = "00011" or  -- SUBBI
				opcode = "00110" or  -- LDI
				opcode = "00111")    -- LOAD
		else '0';

	-- Ativa escrita em registrador (MOV e STORE escrevem fora do ACC)
	reg_wr_en <= '1' when (opcode = "00101" or opcode = "01000") else '0';

	-- Registros fonte
	source_reg <= instruction(2 downto 0) when (opcode = "00001" or -- ADD
							opcode = "00010" or -- SUBB
							opcode = "00111")   -- LOAD
			else
			instruction(5 downto 3) when (opcode = "00101") -- MOV
			else (others => '0');

	-- Registros destino (somente MOV e STORE)
	destiny_reg <= instruction(2 downto 0) when (opcode = "00101" or opcode = "01000")
			else (others => '0');

		    
	-- Entrada da ULA: registrador ou imediato
	sel_ula_src <= '1' when (opcode = "00011" or opcode = "00110") else '0';
	-- SUBBI  LDI => usam imediato

	-- Entrada do ACC: resultado da ULA ou dado direto do registrador
	sel_acc_src <= '1' when opcode = "00111" else '0';
	--  LOAD => vem direto do registrador
	-- senão, por padrão, recebe da ULA

	-- Sinal de borrow para SUBB e SUBBI
	borrow_in <= '1' when (opcode = "00010" or opcode = "00011") else '0';
end architecture;
