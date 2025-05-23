library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
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
end ula;

architecture a_ula of ula is
    signal add_result : unsigned(15 downto 0);
    signal subb_result : unsigned(15 downto 0);
    signal addi_result : unsigned(15 downto 0);
    signal subbi_result : unsigned(15 downto 0);
    signal borrow_signal : unsigned(15 downto 0) := (others => '0');
    signal result_signal : unsigned(15 downto 0);
    signal add_full  : unsigned(16 downto 0);
    signal subb_full : unsigned(16 downto 0);
    signal addi_full  : unsigned(16 downto 0);
    signal subbi_full : unsigned(16 downto 0);
    signal signed_a_msb : std_logic;
    signal signed_second_msb : std_logic;
    signal signed_res_msb : std_logic;

begin
    -- Borrow signal for subtraction
    borrow_signal <= ("0000000000000001") when borrow_in = '1' else
                     ("0000000000000000");

    -- Full adder and subtractor for 16-bit operations
    add_full  <= ('0' & in_a) + ('0' & in_b);
    subb_full <= ('0' & in_a) - ('0' & in_b) - ('0' & borrow_signal);
    addi_full  <= ('0' & in_a) + ('0' & value_immediate);
    subbi_full <= ('0' & in_a) - ('0' & value_immediate) - ('0' & borrow_signal);

    -- Perform operations based on the selected operation
    add_result <= in_a + in_b;
    subb_result <= in_a - in_b - borrow_signal;
    addi_result <= in_a + value_immediate;
    subbi_result <= in_a - value_immediate - borrow_signal;
    result_signal <= add_result when sel_op = "00" else
                    subb_result when sel_op = "01" else
                    addi_result when sel_op = "10" else
                    subbi_result when sel_op = "11" else
                    (others => '0');


    -- Detecting the sign bit for overflow detection
    signed_a_msb <= in_a(15);
    signed_second_msb <= in_b(15) when (sel_op = "00" or sel_op = "01") else
                        value_immediate(15) when (sel_op = "11" or sel_op ="10") else
                        '0';
    signed_res_msb <= result_signal(15);

    -- Zero flag
    zero <= '1' when result_signal = to_unsigned(0, 16) else '0';

    -- Negative flag
    negative <= result_signal(15);

    -- Carry out detection
    carry_out <= '1' when (sel_op = "00" and add_full(16) = '1') or
                         (sel_op = "01" and subb_full(16) = '1') or
                         (sel_op = "10" and addi_full(16) = '1') or
                         (sel_op = "11" and subbi_full(16) = '1')
                 else '0';

    -- Overflow detection
    overflow <= '1' when (signed_a_msb = '0' and signed_second_msb = '0' and signed_res_msb = '1' and (sel_op = "00" or sel_op = "10")) or
                        (signed_a_msb = '1' and signed_second_msb = '1' and signed_res_msb = '0' and (sel_op = "00" or sel_op = "10")) or
                        (signed_a_msb = '0' and signed_second_msb = '1' and signed_res_msb = '1' and (sel_op = "01" or sel_op = "11")) or
                        (signed_a_msb = '1' and signed_second_msb = '0' and signed_res_msb = '0' and (sel_op = "01" or sel_op = "11"))
                    else '0';



    result <= result_signal;

end a_ula;

