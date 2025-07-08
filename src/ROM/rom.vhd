library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk      : in  std_logic;
        endereco : in  unsigned(9 downto 0);
        dado     : out unsigned(13 downto 0)
    );
end entity;

architecture a_rom of rom is
    type mem is array (0 to 1023) of unsigned(13 downto 0);

    -- ISA Reference: ldi:0001, load:0010, store:0011, mov_to_acc:0100, mov_from_acc:0101
    -- add:0110, subb:0111, cmpr:1001, cmpi:1010, jump:1011, bne:1100, bhs:1101, beq:1110, blt:1111
    -- Register Map: R0:000, R1:001, R2:010, R3:011, R4:100

    constant conteudo_rom : mem := (
        -- ===================================================
        -- Part 1: Sieve of Eratosthenes (Unchanged)
        -- ===================================================
        0  => B"0001_001_0000001", -- ldi R1, 1
        1  => B"0001_010_0000001", -- ldi R2, 1
        2  => B"0001_011_0100001", -- ldi R3, 33
        3  => B"0100_010_0000000", -- mov_to_acc R2
        4  => B"0011_010_0000000", -- store [R2]
        5  => B"0100_010_0000000", -- mov_to_acc R2
        6  => B"0110_001_0000000", -- add R1
        7  => B"0101_010_0000000", -- mov_from_acc R2
        8  => B"1001_011_0000000", -- cmpr R3
        9  => B"1100_1111111001", -- bne -7 (to addr 3)
        10 => B"0001_000_0000000", -- ldi R0, 0
        11 => B"0001_100_0000010", -- ldi R4, 2
        12 => B"0001_010_0000100", -- ldi R2, 4
        13 => B"0100_000_0000000", -- mov_to_acc R0
        14 => B"0011_010_0000000", -- store [R2]
        15 => B"0100_010_0000000", -- mov_to_acc R2
        16 => B"0110_100_0000000", -- add R4
        17 => B"0101_010_0000000", -- mov_from_acc R2
        18 => B"1001_011_0000000", -- cmpr R3
        19 => B"1101_0000000010", -- bhs +2 (to addr 22)
        20 => B"1011_0000001101", -- jump 13
        21 => B"1011_0000010110", -- jump 22 (Proceed to CTZ)

        -- ===================================================
        -- Part 2: CTZ Algorithm (Count Trailing Zeros)
        -- ===================================================
        -- R0=count, R1=number_to_test (96), R2=divisor(2), R3=quotient, R4=const_1
        22 => B"0001_000_0000000", -- ldi R0, 0       (count=0)
        23 => B"0001_001_1100000", -- ldi R1, 96      (number=96)
        24 => B"0001_010_0000010", -- ldi R2, 2       (divisor=2)
        25 => B"0001_100_0000001", -- ldi R4, 1       (const 1)
        -- ctz_outer_loop:
        26 => B"0100_001_0000000", -- mov_to_acc R1   (ACC = number)
        27 => B"0001_011_0000000", -- ldi R3, 0       (quotient=0)
        -- ctz_mod2_loop:
        28 => B"1001_010_0000000", -- cmpr R2         (is ACC < 2?)
        29 => B"1111_0000001000", -- blt +8 (to addr 38, end of mod2)
        30 => B"0111_010_0000000", -- subb R2         (ACC = ACC - 2)
        31 => B"0101_001_0000000", -- mov_from_acc R1 (Save new remainder to R1)
        32 => B"0100_011_0000000", -- mov_to_acc R3   (Load quotient)
        33 => B"0110_100_0000000", -- add R4          (quotient++)
        34 => B"0101_011_0000000", -- mov_from_acc R3 (Save new quotient)
        35 => B"0100_001_0000000", -- mov_to_acc R1   (Restore new remainder to ACC)
        36 => B"1011_0000011100", -- jump 28         (Loop back)
        -- check_remainder:
        37 => B"1010_0000000000", -- cmpi 0          (is remainder 0?)
        38 => B"1100_0000000101", -- bne +5 (to addr 44, end_ctz)
        39 => B"0100_000_0000000", -- mov_to_acc R0   (Load count)
        40 => B"0110_100_0000000", -- add R4          (count++)
        41 => B"0101_000_0000000", -- mov_from_acc R0 (Save count)
        42 => B"0100_011_0000000", -- mov_to_acc R3   (ACC = quotient from mod2)
        43 => B"0101_001_0000000", -- mov_from_acc R1 (number = quotient)
        44 => B"1011_0000011010", -- jump 26         (next iteration)
        -- end_ctz:
        45 => B"0100_000_0000000", -- mov_to_acc R0   (ACC = final count)
        46 => B"1010_0000000101", -- cmpi 5
        47 => B"1100_0001010100", -- bne +20 (to FAIL_HALT at addr 68)
        48 => B"1011_0000110001", -- jump 49 (Proceed to Divisor Finder)

        -- ===================================================
        -- Part 3: Prime Divisor Finder (for constant 99)
        -- ===================================================
        -- R0=const(99), R1=prime_ptr, R2=current_prime, R3=temp_const, R4=addr_101
        49 => B"0001_000_1100011", -- ldi R0, 99
        50 => B"0001_001_0000010", -- ldi R1, 2      (prime ptr starts at 2)
        -- find_divisor_loop:
        51 => B"0010_001_0000000", -- load [R1]      (ACC = prime from RAM)
        52 => B"0101_010_0000000", -- mov_from_acc R2 (R2 = current_prime)
        53 => B"0100_000_0000000", -- mov_to_acc R0  (ACC = const)
        -- mod_loop:
        54 => B"1001_010_0000000", -- cmpr R2        (is ACC < prime?)
        55 => B"1111_0000000101", -- blt +5 (to addr 61, end of mod)
        56 => B"0111_010_0000000", -- subb R2
        57 => B"1011_0000110110", -- jump 54
        -- check_mod_result:
        58 => B"1010_0000000000", -- cmpi 0         (is remainder 0?)
        59 => B"1110_0000000101", -- beq +5 (to addr 65, found!)
        60 => B"0100_001_0000000", -- mov_to_acc R1  (Load ptr)
        61 => B"0110_100_0000000", -- add R4         (ptr++)
        62 => B"0101_001_0000000", -- mov_from_acc R1(update ptr)
        63 => B"1011_0000110011", -- jump 51        (next prime)
        -- found_divisor:
        64 => B"0001_100_1100101", -- ldi R4, 101
        65 => B"0100_010_0000000", -- mov_to_acc R2
        66 => B"0011_100_0000000", -- store [R4]
        67 => B"1011_0001000111", -- jump 71 (SUCCESS_HALT)

        -- ===================================================
        -- HALT States
        -- ===================================================
        68 => B"1011_0001001000", -- FAIL_HALT: jump 68
        71 => B"1011_0001000111", -- SUCCESS_HALT: jump 71

        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            dado <= conteudo_rom(to_integer(endereco));
        end if;
    end process;
end architecture;