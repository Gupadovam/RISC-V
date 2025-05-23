library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_reg is
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

architecture a_banco_reg of banco_reg is
    component reg16 is
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
        reg_inst: reg16
            port map (
                clk      => clk,
                rst      => rst,
                wr_en    => wr_enables(i),
                data_in  => data_in,
                data_out => regs_out(i)
            );
    end generate;

    -- Multiplexador para seleção de leitura
    process(rd_sel, regs_out)
    begin
        case to_integer(rd_sel) is
            when 0 => data_out <= regs_out(0);
            when 1 => data_out <= regs_out(1);
            when 2 => data_out <= regs_out(2);
            when 3 => data_out <= regs_out(3);
            when 4 => data_out <= regs_out(4);
            when others => data_out <= (others => '0');
        end case;
    end process;

end architecture;
