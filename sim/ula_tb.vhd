library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end ula_tb;

architecture a_ula_tb of ula_tb is
    component ula
        port(
            in_a, in_b : in unsigned(15 downto 0);
            sel_op : in std_logic_vector(1 downto 0);
            value_immediate : in unsigned(15 downto 0);
            borrow_in : in std_logic;
            carry_out : out std_logic;
            overflow : out std_logic;
            zero : out std_logic;
            negative : out std_logic;
            result : out unsigned(15 downto 0)
        );
    end component;

    -- Sinais internos
    signal in_a, in_b, value_immediate : unsigned(15 downto 0);
    signal sel_op : std_logic_vector(1 downto 0);
    signal borrow_in : std_logic;
    signal carry_out, overflow, zero, negative : std_logic;
    signal result : unsigned(15 downto 0);

begin
    -- Instância da ULA
    uut: ula port map (
        in_a => in_a,
        in_b => in_b,
        sel_op => sel_op,
        value_immediate => value_immediate,
        borrow_in => borrow_in,
        carry_out => carry_out,
        overflow => overflow,
        zero => zero,
        negative => negative,
        result => result
    );

    -- Processo de teste
    process
    begin
        -- Tempo inicial de setup
        wait for 100 ns;

        -- Teste 1: Soma (in_a + in_b)
        in_a <= x"0001";
        in_b <= x"0001";
        value_immediate <= x"0000";
        borrow_in <= '0';
        sel_op <= "00";
        wait for 100 ns;

        -- Teste 2: Subtração (in_a - in_b - borrow)
        in_a <= x"0003";
        in_b <= x"0001";
        value_immediate <= x"0000";
        borrow_in <= '1';
        sel_op <= "01";
        wait for 100 ns;

        -- Teste 3: Soma com imediato (in_a + value_immediate)
        in_a <= x"0002";
        in_b <= x"0000";
        value_immediate <= x"0005";
        borrow_in <= '0';
        sel_op <= "10";
        wait for 100 ns;

        -- Teste 4: Subtração com imediato (in_a - value_immediate - borrow)
        in_a <= x"000A";
        in_b <= x"0000";
        value_immediate <= x"0003";
        borrow_in <= '1';
        sel_op <= "11";
        wait for 100 ns;

        -- Teste 5: Overflow positivo (32767 + 1)
        in_a <= to_unsigned(32767, 16); -- 0x7FFF
        in_b <= to_unsigned(1, 16);
        value_immediate <= x"0000";
        borrow_in <= '0';
        sel_op <= "00";
        wait for 100 ns;

        -- Teste 6: Underflow negativo (0 - 1 - borrow)
        in_a <= x"0000";
        in_b <= x"0001";
        value_immediate <= x"0000";
        borrow_in <= '1';
        sel_op <= "01";
        wait for 100 ns;

        -- Teste 7: Resultado zero
        in_a <= x"0002";
        in_b <= x"0002";
        borrow_in <= '0';
        sel_op <= "01";
        wait for 100 ns;

        -- Teste 8: Todos valores no máximo (FFFF + FFFF)
        in_a <= x"FFFF";
        in_b <= x"FFFF";
        value_immediate <= x"0000";
        borrow_in <= '0';
        sel_op <= "00";
        wait for 100 ns;

        wait;
    end process;
end architecture;
