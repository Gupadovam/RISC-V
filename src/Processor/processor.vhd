library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port(
        clk : in std_logic;
        rst : in std_logic
    );
end entity;

architecture a_processor of processor is
    -- Componentes externos
    component state_machine is
        port(
            clk : in std_logic;
            rst : in std_logic;
            estado : out unsigned(1 downto 0)
        );
    end component;

    component program_counter_manager is
        port(
            clk : in std_logic;
            rst : in std_logic;
            wr_en   : in std_logic;
            jump_en : in std_logic; 
            jump_addr: in unsigned(7 downto 0); 
            br_en   : in std_logic; -- br_enable
            br_addr : in unsigned(7 downto 0); -- br_in
            opcode : in unsigned(4 downto 0);
            beq_cond : in std_logic; -- zero flag
            blt_cond : in std_logic; -- carry flag
            bcs_cond : in std_logic; -- overflow flag
            data_out: out unsigned(7 downto 0) 
        );
    end component;

    component rom is
        port(
            clk : in std_logic;
            endereco : in unsigned(7 downto 0);
            dado : out unsigned(13 downto 0) 
        );
    end component;

    component control_unit is
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
    end component;

    component ula is
        port(
            in_a, in_b : in unsigned(15 downto 0);
            sel_op : in std_logic_vector(1 downto 0);
            value_immediate : in unsigned(8 downto 0);
            borrow_in : in std_logic;
            carry_out : out std_logic;
            overflow : out std_logic;
            zero : out std_logic;
            negative : out std_logic;
            result : out unsigned(15 downto 0)
        );
    end component;

    component acumulador is
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
            wr_sel   : in unsigned(2 downto 0); -- selec. reg escrito
            rd_sel   : in unsigned(2 downto 0); -- selec. reg lido
            data_in  : in unsigned(15 downto 0); 
            data_out : out unsigned(15 downto 0)     
        );
    end component;

    component instruction_register is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(13 downto 0);
            data_out : out unsigned(13 downto 0)
        );
    end component;

    -- Sinais
    signal estado_s : unsigned(1 downto 0);
    signal pc_data_out_s : unsigned(7 downto 0);
    signal pc_wr_en_s : std_logic;
    signal rom_data_out_s : unsigned(13 downto 0);
    signal opcode_s : unsigned(4 downto 0);
    signal jump_en_s : std_logic;
    signal jump_addr_s : unsigned(7 downto 0);
    signal reg_wr_en_s, acc_en_s : std_logic;
    signal sel_op_ula_s : std_logic_vector(1 downto 0);
    signal sel_acc_src_s : std_logic;
    signal source_reg_s, destiny_reg_s : unsigned(2 downto 0);
    signal immediate_s : unsigned(8 downto 0);
    signal borrow_in_s : std_logic;
    signal reg_data_out_s : unsigned(15 downto 0);
    signal ula_in_b_s : unsigned(15 downto 0);
    signal ula_result_s : unsigned(15 downto 0);
    signal acc_data_out_s : unsigned(15 downto 0);
    signal acc_input_s : unsigned(15 downto 0);
    signal ir_data_out_s : unsigned(13 downto 0);
    signal ir_en_s : std_logic;

begin
    -- Componentes principais
    sm: state_machine
        port map(
            clk => clk,
            rst => rst,
            estado => estado_s
        );

    pc: program_counter_manager
        port map(
            clk => clk,
            rst => rst,
            wr_en => pc_wr_en_s,
            jump_en => jump_en_s,
            jump_addr => jump_addr_s,
            opcode => opcode_s,
            data_out => pc_data_out_s
        );

    rom1: rom
        port map(
            clk => clk, 
            endereco => pc_data_out_s,
            dado => rom_data_out_s
        );

    cu: control_unit
        port map(
            clk => clk,
            instruction => ir_data_out_s,
            estado => estado_s,
		  br_en : out std_logic;
		  br_addr : out unsigned(7 downto 0);
		  br_cond : out unsigned(4 downto 0);
            reg_wr_en => reg_wr_en_s,
            sel_op_ula => sel_op_ula_s,
            source_reg => source_reg_s,
            destiny_reg => destiny_reg_s,
            jump_en => jump_en_s,
            jump_addr => jump_addr_s,
            acc_en => acc_en_s,
            immediate => immediate_s,
            sel_acc_src => sel_acc_src_s,
            borrow_in => borrow_in_s,
            pc_en => pc_wr_en_s,
            ir_en => ir_en_s
        );

    br: banco_reg
        port map(
            clk => clk,
            rst => rst,  
            wr_en => reg_wr_en_s,
            wr_sel => destiny_reg_s,
            rd_sel => source_reg_s,
            data_in => acc_data_out_s,
            data_out => reg_data_out_s
        );

    ir: instruction_register
        port map(
            clk => clk,
            rst => rst,
            wr_en => ir_en_s,
            data_in => rom_data_out_s,
            data_out => ir_data_out_s
        );

    ula1: ula
        port map(
            in_a => acc_data_out_s,
            in_b => ula_in_b_s,
            sel_op => sel_op_ula_s,
            value_immediate => immediate_s,
            borrow_in => borrow_in_s,
            carry_out => open,
            overflow => open,
            zero => open,
            negative => open,
            result => ula_result_s
        );

    acc: acumulador
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_en_s,
            data_in => acc_input_s,
            data_out => acc_data_out_s
        );

    -- MUX de entrada da ULA
    ula_in_b_s <= reg_data_out_s;

    -- MUX de entrada do ACC
    acc_input_s <= reg_data_out_s when sel_acc_src_s = '1' else -- For LOAD instruction
                   ula_result_s;  

    -- Opcode extraido para o PC
    opcode_s <= ir_data_out_s(13 downto 9);

end architecture;
