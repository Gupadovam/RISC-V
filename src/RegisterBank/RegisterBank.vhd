library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterBank is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;                  
        wr_sel   : in unsigned(2 downto 0); -- selec. reg escrito
        rd_sel   : in unsigned(2 downto 0); -- selec. reg lido
        data_in  : in unsigned(15 downto 0); 
        data_out : out unsigned(15 downto 0)     
    );
end entity;

architecture a_banco_reg of RegisterBank is
    component Register16Bits is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    -- Definição do tipo de array para os registradores
    type reg_array_t is array(0 to 4) of unsigned(15 downto 0);

    -- Sinal que utiliza esse tipo
    signal regs_out : reg_array_t;
    signal wr_enables : std_logic_vector(0 to 4);
begin

    -- Geração dos sinais individuais de enable para escrita
    gen_wr_en: for i in 0 to 4 generate
        wr_enables(i) <= '1' when (wr_en = '1' and wr_sel = to_unsigned(i, 3)) else '0';
    end generate;

    -- Instanciação dos registradores
    gen_regs: for i in 0 to 4 generate
        reg_inst: Register16Bits
            port map (
                clk      => clk,
                rst      => rst,
                wr_en    => wr_enables(i),
                data_in  => data_in,
                data_out => regs_out(i)
            );
    end generate;

    -- Multiplexador para seleção de leitura
    data_out <= regs_out(to_integer(unsigned(rd_sel))) 
        when (to_integer(unsigned(rd_sel)) < regs_out'length) 
        else (others => '0');

end architecture;
