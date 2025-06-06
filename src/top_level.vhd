library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port (
        clk      : in std_logic;
        rst      : in std_logic;

        wr_acum  : in std_logic;                      -- escreve no acumulador
        wr_bank  : in std_logic;                      -- escreve no banco

        -- Seleções
        sel_reg  : in unsigned(2 downto 0);           -- seleção de registrador do banco (0 a 4)
        sel_op   : in std_logic_vector(1 downto 0);   -- operação da ULA (ADD, SUBB, etc.)

        -- Operando imediato e controle
        value_immediate : in unsigned(15 downto 0);
        borrow_in       : in std_logic;

        -- Entrada para escrita no banco
        data_in  : in unsigned(15 downto 0);

        -- Saídas de depuração
        ula_result : out unsigned(15 downto 0);       
        acum_out   : out unsigned(15 downto 0);       
        flags      : out std_logic_vector(3 downto 0) -- Carry, Overflow, Zero, Negative
    );
end entity;

architecture a_top_level of top_level is

    -- Componentes
    component reg_16 is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    component banco_reg is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            wr_sel   : in unsigned(2 downto 0);
            rd_sel   : in unsigned(2 downto 0);
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    component ula is
        port (
            in_a            : in unsigned(15 downto 0);
            in_b            : in unsigned(15 downto 0);
            sel_op          : in std_logic_vector(1 downto 0);
            value_immediate : in unsigned(15 downto 0);
            borrow_in       : in std_logic;
            carry_out       : out std_logic;
            overflow        : out std_logic;
            zero            : out std_logic;
            negative        : out std_logic;
            result          : out unsigned(15 downto 0)
        );
    end component;

    -- Sinais internos
    signal reg_data     : unsigned(15 downto 0);
    signal acum_data    : unsigned(15 downto 0);
    signal ula_out      : unsigned(15 downto 0);
    signal flag_carry   : std_logic;
    signal flag_ovf     : std_logic;
    signal flag_zero    : std_logic;
    signal flag_neg     : std_logic;

begin

    banco: banco_reg
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_bank,
            wr_sel   => sel_reg,
            rd_sel   => sel_reg,
            data_in  => data_in,
            data_out => reg_data
        );

    acum: reg_16
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_acum,
            data_in  => ula_out,
            data_out => acum_data
        );


    ula_inst: ula
        port map (
            in_a            => acum_data,
            in_b            => reg_data,
            sel_op          => sel_op,
            value_immediate => value_immediate,
            borrow_in       => borrow_in,
            carry_out       => flag_carry,
            overflow        => flag_ovf,
            zero            => flag_zero,
            negative        => flag_neg,
            result          => ula_out
        );

    ula_result <= ula_out;
    acum_out   <= acum_data;
    flags      <= flag_carry & flag_ovf & flag_zero & flag_neg;

end architecture;
