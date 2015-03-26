library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.ALL;
Use Ieee.std_logic_unsigned.all;

entity latch is
  port( in_addr : in std_logic_vector (7 downto 0);
        clk : in std_logic;
        out_addr, pc_addr : out std_logic_vector (7 downto 0)
      );
    end entity;
    
architecture Behav of latch is
  
  signal clear: std_logic :='0';
  
  begin
    
    process (clk)
      begin
        if (clear = '0')then
          out_addr<="00000000";
          pc_addr<="00000000";
          clear<='1';
        
        elsif (clk ='1' and clear = '1') then
          
          out_addr <= in_addr;
          pc_addr <= in_addr;
        
        end if;
      end process;
      
end architecture;