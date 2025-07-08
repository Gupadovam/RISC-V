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

    constant conteudo_rom : mem := (
        -- R0: Constant 0, R1: Constant 1, R2: Address Counter, R3: Loop Limit, R4: Sieve Step
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
        19 => B"1101_0000000001", -- bhs +1 (Branch to HALT)
        20 => B"1011_0000001101", -- jump 13
        -- HALT
        21 => B"1011_0000010101", -- jump 21
        
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