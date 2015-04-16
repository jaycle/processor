library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PC is
port( jump_en, branch_en, clk : in std_logic; 
      jump, offset : in  std_logic_vector (7 downto 0);
      addr : out std_logic_vector (7 downto 0));
end entity;
  
architecture Behav of PC is
signal curr_addr : std_logic_vector (7 downto 0) := "00000000";
begin
   process(clk)
   begin
	if(rising_edge(clk))then
       	if (branch_en = '1' and jump_en = '0') then
    	     curr_addr <= curr_addr + offset + "00000001";		 
    	elsif (branch_en = '0' and jump_en = '1') then
    	    curr_addr <= jump;
		else
    	    curr_addr <= curr_addr + "00000001"; 
    	end if;
	 end if;
	end process;
	addr <= curr_addr;
end architecture;