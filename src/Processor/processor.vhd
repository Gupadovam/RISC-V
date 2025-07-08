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
    -- Component declarations (assuming they are defined as before)
    -- ... (components are the same) ...
    component state_machine is
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            exception : in  std_logic;
            estado    : out unsigned(1 downto 0)
        );
    end component;

    component program_counter_manager is
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            wr_en       : in  std_logic;
            jump_en     : in  std_logic;
            jump_addr   : in  unsigned(9 downto 0);
            br_en       : in  std_logic;
            br_addr     : in  unsigned(9 downto 0);
            instruction : in  unsigned(13 downto 0);
            beq_cond    : in  std_logic;
            bhs_cond    : in  std_logic;
            data_out    : out unsigned(9 downto 0)
        );
    end component;

    component mmu is
        port(
            ram_read_en  : in  std_logic;
            ram_write_en : in  std_logic;
            endereco_in  : in  unsigned(15 downto 0);
            endereco_out : out unsigned(15 downto 0);
            exception    : out std_logic
        );
    end component;

    component rom is
        port(
            clk      : in  std_logic;
            endereco : in  unsigned(9 downto 0);
            dado     : out unsigned(13 downto 0)
        );
    end component;

    component ram is
        port(
            clk      : in  std_logic;
            endereco : in  unsigned(15 downto 0);
            wr_en    : in  std_logic;
            dado_in  : in  unsigned(15 downto 0);
            dado_out : out unsigned(15 downto 0)
        );
    end component;

    component control_unit is
        port(
            clk               : in  std_logic;
            instruction       : in  unsigned(13 downto 0);
            jump_en_out       : out std_logic;
            jump_addr_out     : out unsigned(9 downto 0);
            br_en_out         : out std_logic;
            br_addr_out       : out unsigned(9 downto 0);
            reg_wr_en_out     : out std_logic;
            reg_rd_sel_out    : out unsigned(2 downto 0);
            reg_wr_sel_out    : out unsigned(2 downto 0);
            acc_en_out        : out std_logic;
            rst_acc_out       : out std_logic;
            sel_op_ula_out    : out unsigned(3 downto 0);
            flags_wr_en_out   : out std_logic;
            ram_wr_en_out     : out std_logic;
            ram_rd_en_out     : out std_logic;
            sel_acc_input_out : out std_logic;
            sel_reg_input_out : out std_logic;
            immediate_out     : out unsigned(9 downto 0)
        );
    end component;

    component RegisterBank is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            wr_sel   : in  unsigned(2 downto 0);
            rd_sel   : in  unsigned(2 downto 0);
            data_in  : in  unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    component Register16Bits is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    component Register1Bit is
        port(
            clock    : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  std_logic;
            data_out : out std_logic
        );
    end component;

    component ula is
        port(
            in_a            : in  unsigned(15 downto 0);
            in_b            : in  unsigned(15 downto 0);
            sel_op          : in  unsigned(3 downto 0);
            value_immediate : in  unsigned(9 downto 0);
            borrow_in       : in  std_logic;
            carry_out       : out std_logic;
            overflow        : out std_logic;
            zero            : out std_logic;
            negative        : out std_logic;
            result          : out unsigned(15 downto 0)
        );
    end component;

    -- Signals
    signal estado_s          : unsigned(1 downto 0);
    signal pc_data_out_s     : unsigned(9 downto 0);
    signal rom_data_out_s    : unsigned(13 downto 0);
    signal mmu_exception_s   : std_logic;
    signal mmu_endereco_s    : unsigned(15 downto 0);
    signal ram_data_out_s    : unsigned(15 downto 0);
    signal rb_data_out_s     : unsigned(15 downto 0);
    signal rb_data_in_s      : unsigned(15 downto 0);
    signal acc_out_s         : unsigned(15 downto 0);
    signal acc_in_s          : unsigned(15 downto 0);
    signal ula_out_s         : unsigned(15 downto 0);
    signal ula_zero_s        : std_logic;
    signal ula_carry_s       : std_logic;
    signal fr_zero_flag_s    : std_logic;
    signal fr_carry_flag_s   : std_logic;

    -- Control Unit Signals
    signal cu_jump_en_s      : std_logic;
    signal cu_jump_addr_s    : unsigned(9 downto 0);
    signal cu_br_en_s        : std_logic;
    signal cu_br_addr_s      : unsigned(9 downto 0);
    signal cu_reg_wr_en_s    : std_logic;
    signal cu_reg_rd_sel_s   : unsigned(2 downto 0);
    signal cu_reg_wr_sel_s   : unsigned(2 downto 0);
    signal cu_acc_en_s       : std_logic;
    signal cu_rst_acc_s      : std_logic;
    signal cu_sel_op_ula_s   : unsigned(3 downto 0);
    signal cu_flags_wr_en_s  : std_logic;
    signal cu_ram_wr_en_s    : std_logic;
    signal cu_ram_rd_en_s    : std_logic;
    signal cu_sel_acc_in_s   : std_logic;
    signal cu_sel_reg_in_s   : std_logic;
    signal cu_immediate_s    : unsigned(9 downto 0);
    
    -- Intermediate signals for final enables
    signal execute_en_s      : std_logic;
    signal rb_wr_en_final_s  : std_logic;
    signal acc_wr_en_final_s : std_logic;
    signal mmu_rd_en_final_s : std_logic;
    signal mmu_wr_en_final_s : std_logic;
    signal ram_wr_en_final_s : std_logic;
    signal flags_wr_final_s  : std_logic;

begin
    -- Determine if we are in the execute state
    execute_en_s <= '1' when estado_s = "10" else '0';

    -- Compute final enable signals here
    rb_wr_en_final_s  <= cu_reg_wr_en_s and execute_en_s;
    acc_wr_en_final_s <= cu_acc_en_s and execute_en_s;
    mmu_rd_en_final_s <= cu_ram_rd_en_s and execute_en_s;
    mmu_wr_en_final_s <= cu_ram_wr_en_s and execute_en_s;
    ram_wr_en_final_s <= cu_ram_wr_en_s and execute_en_s;
    flags_wr_final_s  <= cu_flags_wr_en_s and execute_en_s;

    -- Component Instantiations
    sm : state_machine port map(clk, rst, mmu_exception_s, estado_s);

    pc : program_counter_manager port map(
        clk         => clk,
        rst         => rst,
        wr_en       => execute_en_s,
        jump_en     => cu_jump_en_s,
        jump_addr   => cu_jump_addr_s,
        br_en       => cu_br_en_s,
        br_addr     => cu_br_addr_s,
        instruction => rom_data_out_s,
        beq_cond    => fr_zero_flag_s,
        bhs_cond    => fr_carry_flag_s,
        data_out    => pc_data_out_s
    );

    rom1 : rom port map(clk, pc_data_out_s, rom_data_out_s);

    cu : control_unit port map(
        clk               => clk,
        instruction       => rom_data_out_s,
        jump_en_out       => cu_jump_en_s,
        jump_addr_out     => cu_jump_addr_s,
        br_en_out         => cu_br_en_s,
        br_addr_out       => cu_br_addr_s,
        reg_wr_en_out     => cu_reg_wr_en_s,
        reg_rd_sel_out    => cu_reg_rd_sel_s,
        reg_wr_sel_out    => cu_reg_wr_sel_s,
        acc_en_out        => cu_acc_en_s,
        rst_acc_out       => cu_rst_acc_s,
        sel_op_ula_out    => cu_sel_op_ula_s,
        flags_wr_en_out   => cu_flags_wr_en_s,
        ram_wr_en_out     => cu_ram_wr_en_s,
        ram_rd_en_out     => cu_ram_rd_en_s,
        sel_acc_input_out => cu_sel_acc_in_s,
        sel_reg_input_out => cu_sel_reg_in_s,
        immediate_out     => cu_immediate_s
    );

    rb : RegisterBank port map(
        clk      => clk,
        rst      => rst,
        wr_en    => rb_wr_en_final_s, 
        wr_sel   => cu_reg_wr_sel_s,
        rd_sel   => cu_reg_rd_sel_s,
        data_in  => rb_data_in_s,
        data_out => rb_data_out_s
    );

    accumulator : Register16Bits port map(
        clk      => clk,
        rst      => cu_rst_acc_s,
        wr_en    => acc_wr_en_final_s, 
        data_in  => acc_in_s,
        data_out => acc_out_s
    );

    ula1 : ula port map(
        in_a            => acc_out_s,
        in_b            => rb_data_out_s,
        sel_op          => cu_sel_op_ula_s,
        value_immediate => cu_immediate_s,
        borrow_in       => fr_carry_flag_s,
        carry_out       => ula_carry_s,
        overflow        => open,
        zero            => ula_zero_s,
        negative        => open,
        result          => ula_out_s
    );
    
    mmu1 : mmu port map(
        ram_read_en  => mmu_rd_en_final_s, 
        ram_write_en => mmu_wr_en_final_s, 
        endereco_in  => rb_data_out_s,
        endereco_out => mmu_endereco_s,
        exception    => mmu_exception_s
    );

    ram1 : ram port map(
        clk      => clk,
        endereco => mmu_endereco_s,
        wr_en    => ram_wr_en_final_s, 
        dado_in  => acc_out_s,
        dado_out => ram_data_out_s
    );

    flag_zero : Register1bit port map(
        clock    => clk,
        rst      => rst,
        wr_en    => flags_wr_final_s, 
        data_in  => ula_zero_s,
        data_out => fr_zero_flag_s
    );

    flag_carry : Register1bit port map(
        clock    => clk,
        rst      => rst,
        wr_en    => flags_wr_final_s, 
        data_in  => ula_carry_s,
        data_out => fr_carry_flag_s
    );

    -- Data Path Multiplexers
    rb_data_in_s <= acc_out_s when cu_sel_reg_in_s = '1' else resize(cu_immediate_s, 16);
    acc_in_s <= ram_data_out_s when cu_sel_acc_in_s = '1' else ula_out_s;

end architecture;