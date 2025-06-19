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
    component state_machine is
        port(
            clk : in std_logic;
            rst : in std_logic;
            exception : in std_logic;
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
            instruction : in unsigned(13 downto 0);
            beq_cond : in std_logic; -- zero flag
            blt_cond : in std_logic; -- carry flag
            bcs_cond : in std_logic; -- overflow flag
            data_out: out unsigned(7 downto 0) 
        );
    end component;

    component mmu is
        port (
            ram_read_en  : in std_logic;
            ram_write_en : in std_logic;
            endereco_in  : in std_logic_vector(15 downto 0);
            endereco_out : out std_logic_vector(15 downto 0);
            exception    : out std_logic
        );
    end component;

    component rom is
        port(
            clk : in std_logic;
            endereco : in unsigned(7 downto 0);
            dado : out unsigned(13 downto 0) 
        );
    end component;

    component ram is
        port (
            clk      : in std_logic;
            endereco : in unsigned(15 downto 0);
            wr_en    : in std_logic;
            dado_in  : in unsigned(15 downto 0);
            dado_out : out unsigned(15 downto 0) 
        );
    end component;

    component control_unit is
        port(
            clk : in std_logic;
            instruction : in unsigned(13 downto 0);
            estado : in unsigned(1 downto 0);
            jump_en : out std_logic;
            jump_addr : out unsigned(7 downto 0);
            br_en : out std_logic;
            br_addr : out unsigned(7 downto 0);
            br_cond : out unsigned(4 downto 0);
            reg_wr_en : out std_logic;
            sel_op_ula : out std_logic_vector(1 downto 0);
            sel_mux_regs : out std_logic;
            acc_en : out std_logic;
            acc_ovwr_en : out std_logic;
            acc_mux_sel : out std_logic;
            rst_acc : out std_logic;
            flags_wr_en : out std_logic;
            immediate : out unsigned(8 downto 0);
            ram_wr_en : out std_logic;
            ram_rd_en : out std_logic;
            reg_code : out unsigned(2 downto 0)
        );
    end component;

    component RegisterBank is
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;                  
            wr_sel   : in unsigned(2 downto 0); -- selec. reg escrito
            rd_sel   : in unsigned(2 downto 0); -- selec. reg lido
            data_in  : in unsigned(15 downto 0); 
            data_out : out unsigned(15 downto 0)     
        );
    end component;

    component Register1Bit is
        port(
            clock    : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in std_logic;
            data_out : out std_logic
        );
    end component;

    component Register16Bits is
        port(
            clk : in std_logic;
            rst : in std_logic;
            wr_en : in std_logic;
            data_in : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
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

    -- Sinais
    -- state machine
    signal estado_s : unsigned(1 downto 0);

    -- pc
    signal pc_wr_en_s : std_logic;
    signal pc_data_out_s : unsigned(7 downto 0);

    -- mmu
    signal mmu_exception_s : std_logic := '0';
    signal mmu_endereco_s  : unsigned(15 downto 0) := (others => '0');

    -- rom
    signal rom_data_out_s : unsigned(13 downto 0);

    -- ram
    signal ram_data_out_s : unsigned(15 downto 0) := (others => '0');

    -- control unit
    signal cu_jump_en_s : std_logic := '0';
    signal cu_jump_addr_s : unsigned(7 downto 0);
    signal cu_br_en_s : std_logic := '0';
    signal cu_br_addr_s : unsigned(7 downto 0) := (others => '0');
    signal cu_br_cond_s  : unsigned(4 downto 0) := (others => '0');
    signal cu_sel_op_ula_s : std_logic_vector(1 downto 0);
    signal cu_sel_mux_regs_s : std_logic := '0';
    signal cu_reg_wr_en_s : std_logic := '0';
    signal cu_acc_en_s : std_logic := '0';
    signal cu_acc_ovwr_en_s : std_logic := '0';
    signal cu_acc_mux_sel_s : std_logic := '0';
    signal cu_rst_acc_s : std_logic := '0';
    signal cu_flags_wr_en_s : std_logic := '0';
    signal cu_immediate_s : unsigned(8 downto 0);
    signal cu_ram_wr_en_s : std_logic := '0';
    signal cu_ram_rd_en_s : std_logic := '0';
    signal cu_reg_code_s : unsigned(2 downto 0);

    -- register bank
    signal rb_reg_en_s : std_logic;
    signal rb_data_wr_mux_s : unsigned(15 downto 0) := (others => '0');
    signal rb_data_r_s : unsigned(15 downto 0) := (others => '0');

    -- acc 
    signal acc_en_s : std_logic := '0';
    signal acc_out_s : unsigned(15 downto 0) := (others => '0');
    signal acc_in_s : unsigned(15 downto 0) := (others => '0');

    -- ula
    signal ula_out_s : unsigned(15 downto 0) := (others => '0');
    signal ula_carry : std_logic := '0';
    signal ula_zero : std_logic := '0';
    signal ula_negative : std_logic := '0';
    signal ula_overflow : std_logic := '0';

    -- flag registers
    signal fr_zero_flag : std_logic := '0';
    signal fr_carry_flag : std_logic := '0';

begin
    -- Componentes principais
    sm: state_machine
        port map(
            clk => clk,
            rst => rst,
            exception => mmu_exception_s,
            estado => estado_s
        );

    pc: program_counter_manager
        port map(
            clk => clk,
            rst => rst,
            wr_en => pc_wr_en_s,
            jump_en => cu_jump_en_s,
            jump_addr => cu_jump_addr_s,
            br_en => cu_br_en_s,
            br_addr => cu_br_addr_s,
            instruction => rom_data_out_s, -- opcode eh feito dentro do componente
            beq_cond => fr_zero_flag,
            blt_cond => fr_carry_flag,
            bcs_cond => ula_negative,
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
            instruction => rom_data_out_s, 
            estado => estado_s,
            jump_en => cu_jump_en_s,
            jump_addr => cu_jump_addr_s,
            br_en => cu_br_en_s,
            br_addr => cu_br_addr_s,
            br_cond => cu_br_cond_s,
            reg_wr_en => cu_reg_wr_en_s,
            sel_op_ula => cu_sel_op_ula_s,
            sel_mux_regs => cu_sel_mux_regs_s,
            acc_en => cu_acc_en_s,
            acc_ovwr_en => cu_acc_ovwr_en_s,
            acc_mux_sel => cu_acc_mux_sel_s,
            rst_acc => cu_rst_acc_s,
            flags_wr_en => cu_flags_wr_en_s,
            immediate => cu_immediate_s,
            ram_wr_en => cu_ram_wr_en_s,
            ram_rd_en => cu_ram_rd_en_s,
            reg_code => cu_reg_code_s
        );

    rb: RegisterBank
        port map(
            clk => clk,
            rst => rst,  
            wr_en => rb_reg_en_s,
            wr_sel => cu_reg_code_s,
            rd_sel => cu_reg_code_s,
            data_in => rb_data_wr_mux_s,
            data_out => rb_data_r_s
        );

    accumulator: Register16Bits port map(
        clk => clk,
        rst => rst,
        wr_en => acc_en_s,
        data_in => acc_in_s,
        data_out => acc_out_s
    );

    ula1: ula
        port map(
            in_a => acc_out_s,
            in_b => rb_data_r_s,
            sel_op => cu_sel_op_ula_s,
            value_immediate => cu_immediate_s,
            borrow_in => ula_carry,
            carry_out => ula_carry,
            overflow => ula_overflow,
            zero => ula_zero,
            negative => ula_negative,
            result => ula_out_s
        );

    flag_zero: Register1bit port map(
        clock => clk,
        rst => rst,
        wr_en => cu_flags_wr_en_s,
        data_in => ula_zero,
        data_out => fr_zero_flag
    );

    flag_carry: Register1bit port map(
        clock => clk,
        rst => rst,
        wr_en => cu_flags_wr_en_s,
        data_in => ula_carry,
        data_out => fr_carry_flag
    );

    -- enables fetch
    pc_wr_en_s <= '1' when (estado_s = "10" and mmu_exception_s = '0') else '0';

    -- enables decode

    -- enables execute
    cu_acc_en_s <= acc_en_s when estado_s = "01" else '0';
    rb_reg_en_s <= cu_reg_wr_en_s when estado_s = "01" else '0';

    -- registers write data mux
    rb_data_wr_mux_s <= acc_out_s when cu_sel_mux_regs_s = '1' else resize(cu_immediate_s, 16);

    -- acc data input
    acc_in_s <= rb_data_r_s when (cu_acc_ovwr_en_s = '1' and cu_ram_rd_en_s = '0') else
            ram_data_out_s when cu_ram_rd_en_s = '1'
            else unsigned(ula_out_s);

end architecture;
