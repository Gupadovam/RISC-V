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
        -- Part 1: Sieve of Eratosthenes
        -- ===================================================
        -- R0=0, R1=1, R2=Addr_Counter, R3=Limit(33), R4=Sieve_Step
        0  => B"0001_001_0000001", -- ldi R1, 1
        1  => B"0001_010_0000001", -- ldi R2, 1
        2  => B"0001_011_0100001", -- ldi R3, 33
        -- fill_loop:
        3  => B"0100_010_0000000", -- mov_to_acc R2
        4  => B"0011_010_0000000", -- store [R2]
        5  => B"0100_010_0000000", -- mov_to_acc R2
        6  => B"0110_001_0000000", -- add R1
        7  => B"0101_010_0000000", -- mov_from_acc R2
        8  => B"1001_011_0000000", -- cmpr R3
        9  => B"1100_1111111001", -- bne -7 (to addr 3)
        -- Sieve for 2
        10 => B"0001_000_0000000", -- ldi R0, 0
        11 => B"0001_100_0000010", -- ldi R4, 2
        12 => B"0001_010_0000100", -- ldi R2, 4
        -- sieve_loop_2:
        13 => B"0100_000_0000000", -- mov_to_acc R0
        14 => B"0011_010_0000000", -- store [R2]
        15 => B"0100_010_0000000", -- mov_to_acc R2
        16 => B"0110_100_0000000", -- add R4
        17 => B"0101_010_0000000", -- mov_from_acc R2
        18 => B"1001_011_0000000", -- cmpr R3
        19 => B"1101_0000000010", -- bhs +2 (to addr 22, end of loop)
        20 => B"1011_0000001101", -- jump 13
        21 => B"1011_0000010110", -- jump 22 (Proceed to Sieve for 3)

        --  Sieve for 3
        22 => B"0001_100_0000011", -- ldi R4, 3
        23 => B"0001_010_0000110", -- ldi R2, 6
        -- sieve_loop_3:
        24 => B"0100_000_0000000", -- mov_to_acc R0
        25 => B"0011_010_0000000", -- store [R2]
        26 => B"0100_010_0000000", -- mov_to_acc R2
        27 => B"0110_100_0000000", -- add R4
        28 => B"0101_010_0000000", -- mov_from_acc R2
        29 => B"1001_011_0000000", -- cmpr R3
        30 => B"1101_0000000010", -- bhs +2 (to addr 33, end of loop)
        31 => B"1011_0000011000", -- jump 24
        32 => B"1011_0000100001", -- jump 33 (Proceed to Sieve for 5)

        -- Sieve for 5
        33 => B"0001_100_0000101", -- ldi R4, 5
        34 => B"0001_010_0001010", -- ldi R2, 10
        -- sieve_loop_5:
        35 => B"0100_000_0000000", -- mov_to_acc R0
        36 => B"0011_010_0000000", -- store [R2]
        37 => B"0100_010_0000000", -- mov_to_acc R2
        38 => B"0110_100_0000000", -- add R4
        39 => B"0101_010_0000000", -- mov_from_acc R2
        40 => B"1001_011_0000000", -- cmpr R3
        41 => B"1101_0000000010", -- bhs +2 (to addr 44, end of loop)
        42 => B"1011_0000100011", -- jump 35
        43 => B"1011_0000101100", -- jump 44 (Proceed to CTZ)

        -- ===================================================
        -- Part 2: CTZ Algorithm (Re-addressed)
        -- ===================================================
        44 => B"0001_000_0000000", -- ldi R0, 0
        45 => B"0001_001_1100000", -- ldi R1, 96
        46 => B"0001_010_0000010", -- ldi R2, 2
        47 => B"0001_100_0000001", -- ldi R4, 1
        48 => B"0100_001_0000000", -- mov_to_acc R1
        49 => B"0001_011_0000000", -- ldi R3, 0
        50 => B"1001_010_0000000", -- cmpr R2
        51 => B"1111_0000001000", -- blt +8 (to addr 60)
        52 => B"0111_010_0000000", -- subb R2
        53 => B"0101_001_0000000", -- mov_from_acc R1
        54 => B"0100_011_0000000", -- mov_to_acc R3
        55 => B"0110_100_0000000", -- add R4
        56 => B"0101_011_0000000", -- mov_from_acc R3
        57 => B"0100_001_0000000", -- mov_to_acc R1
        58 => B"1011_0000110010", -- jump 50
        59 => B"1010_0000000000", -- cmpi 0
        60 => B"1100_0000000101", -- bne +5 (to addr 66)
        61 => B"0100_000_0000000", -- mov_to_acc R0
        62 => B"0110_100_0000000", -- add R4
        63 => B"0101_000_0000000", -- mov_from_acc R0
        64 => B"0100_011_0000000", -- mov_to_acc R3
        65 => B"0101_001_0000000", -- mov_from_acc R1
        66 => B"1011_0000110000", -- jump 48
        67 => B"0100_000_0000000", -- mov_to_acc R0
        68 => B"1010_0000000101", -- cmpi 5
        69 => B"1100_0001010100", -- bne +20 (to FAIL_HALT at addr 90)
        70 => B"1011_0001000111", -- jump 71

        -- ===================================================
        -- Part 3: Prime Divisor Finder (Re-addressed)
        -- ===================================================
        71 => B"0001_000_1100011", -- ldi R0, 99
        72 => B"0001_001_0000010", -- ldi R1, 2
        73 => B"0010_001_0000000", -- load [R1]
        74 => B"0101_010_0000000", -- mov_from_acc R2
        75 => B"0100_000_0000000", -- mov_to_acc R0
        76 => B"1001_010_0000000", -- cmpr R2
        77 => B"1111_0000000101", -- blt +5 (to addr 83)
        78 => B"0111_010_0000000", -- subb R2
        79 => B"1011_0001001100", -- jump 76
        80 => B"1010_0000000000", -- cmpi 0
        81 => B"1110_0000000101", -- beq +5 (to addr 87)
        82 => B"0100_001_0000000", -- mov_to_acc R1
        83 => B"0110_100_0000000", -- add R4
        84 => B"0101_001_0000000", -- mov_from_acc R1
        85 => B"1011_0001001001", -- jump 73
        86 => B"0001_100_1100101", -- ldi R4, 101
        87 => B"0100_010_0000000", -- mov_to_acc R2
        88 => B"0011_100_0000000", -- store [R4]
        89 => B"1011_0001011011", -- jump 91 (SUCCESS_HALT)

        -- ===================================================
        -- HALT States (Re-addressed)
        -- ===================================================
        90 => B"1011_0001011010", -- FAIL_HALT: jump 90
        91 => B"1011_0001011011", -- SUCCESS_HALT: jump 91

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