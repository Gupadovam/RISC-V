library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
        -- System Inputs
        clk         : in  std_logic;
        instruction : in  unsigned(13 downto 0);

        -- Control Outputs
        -- PC Control
        jump_en_out     : out std_logic;
        jump_addr_out   : out unsigned(9 downto 0);
        br_en_out       : out std_logic;
        br_addr_out     : out unsigned(9 downto 0);

        -- Register Bank Control
        reg_wr_en_out   : out std_logic;
        reg_rd_sel_out  : out unsigned(2 downto 0);
        reg_wr_sel_out  : out unsigned(2 downto 0);
        
        -- Accumulator Control
        acc_en_out      : out std_logic;
        rst_acc_out     : out std_logic;
        
        -- ULA Control
        sel_op_ula_out  : out unsigned(3 downto 0); -- Extended to support more ops
        flags_wr_en_out : out std_logic;
        
        -- Memory Control
        ram_wr_en_out   : out std_logic;
        ram_rd_en_out   : out std_logic;

        -- Data Path Mux Selects & Immediate Value
        sel_acc_input_out : out std_logic; -- '0' for ULA result, '1' for RAM data
        sel_reg_input_out : out std_logic; -- '0' for Immediate, '1' for ACC
        immediate_out     : out unsigned(9 downto 0)
    );
end entity;

architecture a_control_unit of control_unit is
    -- Instruction Fields
    signal opcode : unsigned(3 downto 0);
    signal ddd    : unsigned(2 downto 0); -- Destination Register
    signal sss    : unsigned(2 downto 0); -- Source Register
    signal aaa    : unsigned(2 downto 0); -- Address Register
    signal imm7   : unsigned(6 downto 0);
    signal imm10  : unsigned(9 downto 0);

begin
    -- Decode instruction fields
    opcode <= instruction(13 downto 10);
    ddd    <= instruction(9 downto 7);
    sss    <= instruction(9 downto 7); -- SSS, DDD, AAA fields overlap
    aaa    <= instruction(9 downto 7);
    imm7   <= instruction(6 downto 0);
    imm10  <= instruction(9 downto 0);

    -- Combinational logic to generate control signals based on opcode
    process(opcode, ddd, sss, aaa, imm7, imm10)
    begin
        -- Default values (inactive state)
        jump_en_out       <= '0';
        jump_addr_out     <= (others => '0');
        br_en_out         <= '0';
        br_addr_out       <= (others => '0');
        reg_wr_en_out     <= '0';
        reg_rd_sel_out    <= (others => '0');
        reg_wr_sel_out    <= (others => '0');
        acc_en_out        <= '0';
        rst_acc_out       <= '0';
        sel_op_ula_out    <= "0000"; -- Default to NOP/Pass
        flags_wr_en_out   <= '0';
        ram_wr_en_out     <= '0';
        ram_rd_en_out     <= '0';
        sel_acc_input_out <= '0'; -- Default to ULA result
        sel_reg_input_out <= '0'; -- Default to Immediate
        immediate_out     <= (others => '0');

        case opcode is
            -- NOP
            when "0000" =>
                null; -- All signals remain at default

            -- ldi Rd, imm
            when "0001" =>
                reg_wr_en_out     <= '1';
                reg_wr_sel_out    <= ddd;
                sel_reg_input_out <= '0'; -- Select immediate as input to reg bank
                immediate_out     <= resize(imm7, immediate_out'length);

            -- load [Ra]
            when "0010" =>
                acc_en_out        <= '1';
                ram_rd_en_out     <= '1';
                reg_rd_sel_out    <= aaa; -- Read address from register Ra
                sel_acc_input_out <= '1'; -- Select RAM data as input to ACC

            -- store [Ra]
            when "0011" =>
                ram_wr_en_out     <= '1';
                reg_rd_sel_out    <= aaa; -- Read address from register Ra

            -- mov_to_acc Rs
            when "0100" =>
                acc_en_out        <= '1';
                reg_rd_sel_out    <= sss;
                sel_op_ula_out    <= "0000"; -- Use ULA in pass-through mode (B)
                sel_acc_input_out <= '0'; -- Select ULA result

            -- mov_from_acc Rd
            when "0101" =>
                reg_wr_en_out     <= '1';
                reg_wr_sel_out    <= ddd;
                sel_reg_input_out <= '1'; -- Select ACC as input to reg bank

            -- add Rs
            when "0110" =>
                acc_en_out        <= '1';
                flags_wr_en_out   <= '1';
                reg_rd_sel_out    <= sss;
                sel_op_ula_out    <= "0001"; -- ULA OP: ADD

            -- subb Rs
            when "0111" =>
                acc_en_out        <= '1';
                flags_wr_en_out   <= '1';
                reg_rd_sel_out    <= sss;
                sel_op_ula_out    <= "0010"; -- ULA OP: SUBB

            -- subi imm
            when "1000" =>
                acc_en_out        <= '1';
                flags_wr_en_out   <= '1';
                sel_op_ula_out    <= "0011"; -- ULA OP: SUBI
                immediate_out     <= imm10;

            -- cmpr Rs
            when "1001" =>
                flags_wr_en_out   <= '1';
                reg_rd_sel_out    <= sss;
                sel_op_ula_out    <= "0100"; -- ULA OP: CMP (SUB without write)

            -- cmpi imm
            when "1010" =>
                flags_wr_en_out   <= '1';
                sel_op_ula_out    <= "0101"; -- ULA OP: CMPI (SUBI without write)
                immediate_out     <= imm10;

            -- jump addr
            when "1011" =>
                jump_en_out       <= '1';
                jump_addr_out     <= imm10;

            -- bne offset
            when "1100" =>
                br_en_out         <= '1';
                br_addr_out       <= imm10;

            -- bhs offset
            when "1101" =>
                br_en_out         <= '1';
                br_addr_out       <= imm10;

            -- zac (Not in final ISA, but can be implemented as mov_to_acc with a zeroed register)
            -- For a dedicated instruction, you would add a new opcode.
            -- For now, use ldi R_zero, 0 and mov_to_acc R_zero.
            
            when others =>
                null; -- All signals remain at default

        end case;
    end process;

end architecture;