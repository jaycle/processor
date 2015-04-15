library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu is
  port( -- in/out variables
        
        a_in,b_in : in std_logic_vector (7 downto 0);
        op,sel : in std_logic_vector (3 downto 0);
        offset, alu_out : out std_logic_vector (7 downto 0)   
  );
end entity;

architecture behav of alu is

begin

process ( a_in,b_in,op,sel)
   
      
      variable a ,b : std_logic_vector(7 downto 0);
      variable z : std_logic_vector (7 downto 0);
      variable shift: integer;
      
      
   begin
     
     a:= a_in;
     b:= b_in;
     
     shift := conv_integer(b);
     
case op is
  
    
when "0001" => alu_out <= a + b; 
  
when "0010" => 
		if sel="0000" then
		alu_out <= a+b;
	
		elsif sel="0001" then
		alu_out <= a-b;
		end if;
  
when "0011" => 
		if sel="0000" then
		alu_out <= a+1;
		
		elsif sel="0001" then
		alu_out <= a-1;
		end if;
  
when "0100" => 
		if sel="0000" then
		alu_out <= to_stdlogicvector(to_bitvector(a) sll shift);
			
		elsif sel="0001" then
		alu_out <= to_stdlogicvector(to_bitvector(a) srl shift);
		
		end if;
  
when "0101" => 
		if sel="0000" then
		alu_out <= not a;
		
   	elsif sel="0001" then
		alu_out <= a NOR b;

    elsif sel="0010" then
		alu_out <= a NAND b;
		
    elsif sel="0011" then
		alu_out <= a XOR b;
	
    elsif sel="0100" then
		 alu_out <= a AND b;
		
    elsif sel="0101" then
		 alu_out <= a OR b;
 
    elsif sel="0110" then
		  alu_out <= "00000000"; 
  
    elsif sel="0111" then
		  alu_out <= "11111111";
	
    elsif sel="1111" then
		    if a<b then alu_out<="11111111"; end if;
		
		elsif sel="1000" then
		    alu_out <= b; 
		  
		end if;
		
when others => null;
  
end case;

end process;

end behav;
