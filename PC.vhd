library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PC is
port( jump_en, branch_en : in std_logic; 
      wr_addr, jump, offset : in  std_logic_vector (7 downto 0);
      addr : out std_logic_vector (7 downto 0)
      
      );
  end entity;
  
  architecture Behav of PC is
  
    
   signal clear : std_logic:='0';
   begin


    
   process(branch_en, offset, wr_addr, jump_en,jump,clear)
   begin
      if (clear = '0')then
          addr<="00000000";
          clear<='1';
          
      elsif (branch_en = '0' and jump_en = '0' and clear ='1') then
        addr <= wr_addr + "00000001"; 
        
      
      elsif (branch_en = '1' and jump_en = '0' and clear ='1') then
         addr <= wr_addr + offset + "00000001";
        
      elsif (branch_en = '0' and jump_en = '1' and clear ='1') then
        addr <= jump;
        
      end if;
    end process;

end architecture;