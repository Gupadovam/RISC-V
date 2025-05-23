library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;

architecture a_tb of top_level_tb is

    component top_level is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_acum  : in std_logic;
            wr_bank  : in std_logic;
            sel_reg  : in unsigned(2 downto 0);
            sel_op   : in std_logic_vector(1 downto 0);
            value_immediate : in unsigned(15 downto 0);
            borrow_in       : in std_logic;
            data_in         : in unsigned(15 downto 0);
            ula_result      : out unsigned(15 downto 0);
            acum_out        : out unsigned(15 downto 0);
            flags           : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Sinais de teste
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '0';
    signal wr_acum_tb  : std_logic := '0';
    signal wr_bank_tb  : std_logic := '0';
    signal sel_reg_tb  : unsigned(2 downto 0) := (others => '0');
    signal sel_op_tb   : std_logic_vector(1 downto 0) := "00";
    signal value_immediate_tb : unsigned(15 downto 0) := (others => '0');
    signal borrow_in_tb : std_logic := '0';
    signal data_in_tb   : unsigned(15 downto 0) := (others => '0');
    signal ula_result_tb : unsigned(15 downto 0);
    signal acum_out_tb   : unsigned(15 downto 0);
    signal flags_tb      : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 100 ns;

begin

    -- Instância do DUT (top_level)
    DUT: top_level
        port map (
            clk => clk_tb,
            rst => rst_tb,
            wr_acum => wr_acum_tb,
            wr_bank => wr_bank_tb,
            sel_reg => sel_reg_tb,
            sel_op => sel_op_tb,
            value_immediate => value_immediate_tb,
            borrow_in => borrow_in_tb,
            data_in => data_in_tb,
            ula_result => ula_result_tb,
            acum_out => acum_out_tb,
            flags => flags_tb
        );

    -- Geração de clock
    clk_process : process
    begin
        while now < 2 us loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Processo de reset
    rst_process : process
    begin
        rst_tb <= '1';
        wait for CLK_PERIOD;
        rst_tb <= '0';
        wait;
    end process;

    -- Teste
    stim_proc : process
    begin
        wait for CLK_PERIOD;
		-- wait until rst_tb = '0';
        -- wait until rising_edge(clk_tb);

        -- LD A, #10
        value_immediate_tb <= to_unsigned(10, 16);
        sel_op_tb <= "10"; -- ADDI
        borrow_in_tb <= '0';
        wr_acum_tb <= '1';
        wait for CLK_PERIOD;
        wr_acum_tb <= '0';

        -- MOV R1, A
        sel_reg_tb <= to_unsigned(1, 3);
        data_in_tb <= acum_out_tb;
        wr_bank_tb <= '1';
        wait for CLK_PERIOD;
        wr_bank_tb <= '0';

        -- ADDI A, A, #5
        value_immediate_tb <= to_unsigned(5, 16);
        sel_op_tb <= "10";
        wr_acum_tb <= '1';
        wait for CLK_PERIOD;
        wr_acum_tb <= '0';

        -- ADD A, A, R1
        sel_op_tb <= "00"; -- ADD
        sel_reg_tb <= to_unsigned(1, 3);
        wr_acum_tb <= '1';
        wait for CLK_PERIOD;
        wr_acum_tb <= '0';

        -- SUBB A, A, R1
        sel_op_tb <= "01"; -- SUBB
        borrow_in_tb <= '0';
        wr_acum_tb <= '1';
        wait for CLK_PERIOD;
        wr_acum_tb <= '0';

        wait;
    end process;

end architecture;
