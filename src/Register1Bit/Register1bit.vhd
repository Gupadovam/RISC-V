library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register1bit is
   port(
      clock    : in std_logic;
      rst      : in std_logic;
      wr_en    : in std_logic;
      data_in  : in std_logic;
      data_out : out std_logic
   );
end entity;

architecture a_Register1bit of Register1bit is
   signal register_s: std_logic := '0';
begin
   process(clock, rst, wr_en) 
   begin                
      if rst='1' then
         register_s <= '0';
      elsif wr_en='1' then
         if rising_edge(clock) then
            register_s <= data_in;
         end if;
      end if;
   end process;
   data_out <= register_s;
end architecture;