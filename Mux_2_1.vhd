library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

entity mux_2_1 is
    Port (selectL : in std_logic;
          Min1 : in std_logic_vector(7 downto 0);
          Min2 : in std_logic_vector(7 downto 0);
          muxout : out std_logic_vector(7 downto 0)
          );
end mux_2_1;

architecture Behavioral of mux_2_1 is

begin 

process(selectL,Min1, Min2)
begin
  if selectL = '0' then
    muxout <= Min1;
  elsif selectL = '1' then
    muxout <= Min2;
  end if;
			
end process;
end Behavioral;