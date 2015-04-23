library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity PC is
port( jump_en, branch_en, clk : in std_logic; 
      jump, offset : in  std_logic_vector (7 downto 0);
      addr : out std_logic_vector (7 downto 0));
end entity;
  
architecture Behav of PC is
signal curr_addr : unsigned (7 downto 0) := "00000000";
begin
   process(clk)
	variable br_off : integer;
   begin
	if(rising_edge(clk))then
       	if (branch_en = '1' and jump_en = '0') then
			 br_off := to_integer(signed(offset)) + 1;
    	     curr_addr <= curr_addr + br_off;
    	elsif (branch_en = '0' and jump_en = '1') then
    	    curr_addr <= unsigned(jump);
		else
    	    curr_addr <= curr_addr + 1;
    	end if;
	 end if;
	end process;
	addr <= std_logic_vector(curr_addr);
end architecture;