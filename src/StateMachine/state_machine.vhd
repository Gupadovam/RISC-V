library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 00: Fetch
-- 01: Decode
-- 10: Execute

entity state_machine is
    port(
        clk : in std_logic;
        rst : in std_logic;
        exception : in std_logic;
        estado : out unsigned(1 downto 0)
    );
end entity;

architecture a_StateMachine of state_machine is
    signal estado_s : unsigned(1 downto 0); 
    begin
        process(clk, rst)
        begin
            if rst = '1' then
                estado_s <= "00"; 
            elsif rising_edge(clk) then
                if exception = '1' then 
                    estado_s <= "01";            
                elsif estado_s = "10" then       
                    estado_s <= "00";            
                else
                    estado_s <= estado_s + 1;   
                end if;
            end if;
    end process;

    estado <= estado_s; 
end architecture;