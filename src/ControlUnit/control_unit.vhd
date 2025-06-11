library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
		  clk : in std_logic;
		  instruction : in unsigned(13 downto 0);
		  estado : in unsigned(1 downto 0);
		  br_en : out std_logic;
		  br_addr : out unsigned(7 downto 0);
		  br_cond : out unsigned(4 downto 0);
		  reg_wr_en : out std_logic;
		  sel_op_ula : out std_logic_vector(1 downto 0);
		  source_reg : out unsigned(2 downto 0);
		  destiny_reg : out unsigned(2 downto 0);
		  jump_en : out std_logic;
		  jump_addr : out unsigned(7 downto 0);
		  acc_en : out std_logic;
		  immediate : out unsigned(8 downto 0);
		  sel_acc_src : out std_logic;
		  borrow_in : out std_logic;
		  pc_en : out std_logic;
		  ir_en : out std_logic -- ir := instruction register
    );
end entity;

architecture a_control_unit of control_unit is
    signal opcode : unsigned(4 downto 0);

	constant FETCH : unsigned(1 downto 0) := "00";
	constant DECODE : unsigned(1 downto 0) := "01";
	constant EXECUTE : unsigned(1 downto 0) := "10";
begin

	-- Extrai o opcode
	opcode <= instruction(13 downto 9);

    -- verifica se eh branch
    br_en <= '1' when (opcode>="00011" and opcode<="01000") else '0';
    br_addr <= instruction(7 downto 0);
    br_cond <= opcode; 

	process(clk)
	begin
		if rising_edge(clk) then
			case estado is
				when FETCH =>
					ir_en <= '0';
					pc_en <= '0';
					reg_wr_en <= '0';
					acc_en <= '0';
					jump_en <= '0';
					immediate <= (others => '0');
					sel_op_ula <= "10"; -- Default NOP
					source_reg <= (others => '0');
					destiny_reg <= (others => '0');
					sel_acc_src <= '0';
					borrow_in <= '0';
					ir_en <= '1';

				when DECODE =>
					-- Ativa escrita em registrador (MOV e STORE escrevem fora do ACC)
					if (opcode = "00101" or opcode = "01000") then -- MOV and STORE
						reg_wr_en <= '1';
					end if;

					-- Registros destino (somente MOV e STORE)
					if (opcode = "00101" or opcode = "01000") then -- MOV and STORE
						destiny_reg <= instruction(2 downto 0);
					end if;

				when EXECUTE =>
					-- It activates the approp. control signals
					pc_en <= '1';

					-- Immediate: SUBBI 
					if (opcode = "00011" or opcode = "00110") then
						immediate <= instruction(8 downto 0);
					else 
						immediate <= (others => '0');
					end if;

					-- Sinal de pulo
					if opcode = "00100" then
                        jump_en <= '1';
                        jump_addr <= instruction(7 downto 0);
                    end if;

					-- Seleção da operação da ULA
					if opcode = "00001" then    -- ADD
                        sel_op_ula <= "00";
                    elsif opcode = "00010" then -- SUBB
                        sel_op_ula <= "01";
                    elsif opcode = "00011" then -- SUBBI
                        sel_op_ula <= "11";
                    end if;

					-- Ativa escrita no acumulador (único destino em ADD, SUBB, etc.)
					if (opcode = "00001" or          -- ADD
						opcode = "00010" or          -- SUBB
						opcode = "00011" or          -- SUBBI
						opcode = "00110" or          -- LDI
						opcode = "00111") then       -- LOAD
						acc_en <= '1';
					end if;

					-- Registros fonte
				    if (opcode = "00001" or          -- ADD
						opcode = "00010" or          -- SUBB
						opcode = "00111") then       -- LOAD
						source_reg <= instruction(2 downto 0);
					elsif opcode = "00101" then      -- MOV
						source_reg <= instruction(5 downto 3);
					end if;
							
					-- Entrada do ACC: resultado da ULA ou dado direto do registrador
					if opcode = "00111" then         -- LOAD
						sel_acc_src <= '1';
					end if;

					-- Sinal de borrow para SUBB e SUBBI
					if (opcode = "00010" or opcode = "00011") then -- SUBB or SUBBI
						borrow_in <= '1';
					end if;

				when others =>
					-- It handles others states
					ir_en <= '0';
					pc_en <= '0';
					reg_wr_en <= '0';
					acc_en <= '0';
					jump_en <= '0';
			end case;
		end if;
	end process;
end architecture;
