library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port(
        in_a            : in  unsigned(15 downto 0);
        in_b            : in  unsigned(15 downto 0);
        sel_op          : in  unsigned(3 downto 0);
        value_immediate : in  unsigned(9 downto 0);
        borrow_in       : in  std_logic; -- This is the Carry Flag (C)
        carry_out       : out std_logic;
        overflow        : out std_logic;
        zero            : out std_logic;
        negative        : out std_logic;
        result          : out unsigned(15 downto 0)
    );
end ula;

architecture a_ula of ula is
    signal ula_result_s : unsigned(15 downto 0);
    signal ula_flags_s  : unsigned(15 downto 0);
    signal extended_imm : unsigned(15 downto 0);
    signal second_op    : unsigned(15 downto 0);
    signal full_result  : unsigned(16 downto 0);
    signal borrow_to_subtract_vec : unsigned(16 downto 0); -- Vector for the value to subtract as borrow

begin
    extended_imm <= resize(value_immediate, 16);
    second_op    <= extended_imm when (sel_op = "0011" or sel_op = "0101") else in_b;

    -- **FIXED**: Correctly calculate the borrow for SUBB.
    -- A standard SUBB performs A - B - (1 - C). The borrow value is NOT(C).
    -- For all other subtractions (SUBI, CMP), the borrow is 0.
    borrow_to_subtract_vec <= (0 => not borrow_in, others => '0') when sel_op = "0010" else
                              (others => '0');

    process(sel_op, in_a, second_op, borrow_to_subtract_vec)
    begin
        case sel_op is
            when "0001" => -- ADD
                full_result <= ('0' & in_a) + ('0' & second_op);
            when "0010" => -- SUBB
                full_result <= (('0' & in_a) - ('0' & second_op)) - borrow_to_subtract_vec;
            when "0011" | "0100" | "0101" => -- SUBI, CMPR, CMPI
                full_result <= ('0' & in_a) - ('0' & second_op);
            when "0000" => -- Pass-through B for mov_to_acc
                full_result <= resize(second_op, 17);
            when others =>
                full_result <= (others => '0');
        end case;
    end process;

    ula_flags_s  <= full_result(15 downto 0);
    ula_result_s <= ula_flags_s when (sel_op = "0001" or sel_op = "0010" or sel_op = "0011" or sel_op = "0000") else (others => '0');
    
    carry_out <= not full_result(16) when (sel_op = "0010" or sel_op = "0011" or sel_op = "0100" or sel_op = "0101") else
                 full_result(16);

    zero      <= '1' when ula_flags_s = 0 else '0';
    negative  <= ula_flags_s(15);
    result    <= ula_result_s;
    overflow  <= '0';

end architecture;