library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
		  clk : in std_logic;
        instruction : in unsigned(13 downto 0);
		  reg_wr_en : out std_logic;
		  sel_op_ula : out unsigned(1 downto 0);
		  source_reg : out unsigned(2 downto 0);
		  destiny_reg : out unsigned(2 downto 0);
        jump_en : out std_logic;
        jump_addr : out unsigned(7 downto 0);
		  acc_en : out std_logic;
		  immediate : out unsigned(5 downto 0);
    );
end entity;

architecture a_control_unit of control_unit is
    signal opcode : unsigned(4 downto 0) := (others => '0');

    begin
		  -- opcode
        opcode <= instruction(13 downto 9);
		  
		  -- cte
	     immediate <= instruction(8 downto 3) when opcode = "00011" else "000000";
		  
		  -- verifica se eh pulo
        jump_en <= '1' when opcode = "00100" else '0';
        jump_addr <= instruction(7 downto 0);

		  -- seleciona operacao ULA
		  sel_op_ula <= "00" when opcode = "00001" else -- add
						  "01" when opcode = "00010" else -- subb
						  "11" when opcode = "00011" else -- subbi
						  "00";
end architecture;
