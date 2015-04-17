library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_final is
  port( -- in/out variables
        
        rx_in,ry_in : in std_logic_vector (7 downto 0);
        op,sel : in std_logic_vector (3 downto 0);
        alu_out : out std_logic_vector (7 downto 0);
	z_flag : out std_logic   
  );
end entity;

architecture behav of alu_final is

begin

process ( rx_in,ry_in,op,sel)
   
      
      variable rx ,ry : std_logic_vector(7 downto 0);
      variable z : std_logic_vector (7 downto 0);
      variable shift: integer;
      
      
   begin
     
     z_flag <= '0';
     rx:= rx_in;
     ry:= ry_in;
     
     shift := conv_integer(ry);
     
case op is
  
    
when "0001" => alu_out <= rx + ry; 
  
when "0010" => 
		if sel="0000" then
		alu_out <= rx+ry;
	
		elsif sel="0001" then
		alu_out <= rx-ry;
		end if;
  
when "0011" => 
		if sel="0000" then
		alu_out <= rx+1;
		
		elsif sel="0001" then
		alu_out <= rx-1;
		end if;
  
when "0100" => 
		if sel="0000" then
		alu_out <= to_stdlogicvector(to_bitvector(rx) sll shift);
			
		elsif sel="0001" then
		alu_out <= to_stdlogicvector(to_bitvector(rx) srl shift);
		
		end if;
  
when "0101" => 
		if sel="0000" then
		alu_out <= not rx;
		
   	elsif sel="0001" then
		alu_out <= rx NOR ry;

    elsif sel="0010" then
		alu_out <= rx NAND ry;
		
    elsif sel="0011" then
		alu_out <= rx XOR ry;
	
    elsif sel="0100" then
		 alu_out <= rx AND ry;
		
    elsif sel="0101" then
		 alu_out <= rx OR ry;
 
    elsif sel="0110" then		-- clear
		  alu_out <= "00000000"; 
  
    elsif sel="0111" then		-- set
		  alu_out <= "11111111";

    elsif sel="1111" then		-- set if less than
	    if rx_in<ry_in then 
			alu_out<="11111111"; 
		end if;

    elsif sel="1000" then		-- Move (Ry <= Rx)
		    alu_out <= rx; 
		  
	end if;

when "1101" =>		-- Branch if Zero
    if rx_in=0 then 
		alu_out<="00000000"; 
		z_flag <= '1';
   end if;	  
    
when "1110" =>	    -- branch if not zero
	if rx_in=0  then 
		alu_out<="00000000"; 
		z_flag <= '1';
	end if;	
	
when others => 
	alu_out <= "00000000";
	z_flag <= '0';
  
end case;

end process;

end behav;
