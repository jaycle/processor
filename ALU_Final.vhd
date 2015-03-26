library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.ALL;
Use Ieee.std_logic_unsigned.all;


entity ALU_Final is 
  port(
        Rx : in std_logic_vector( 7 downto 0);
        Ry: in std_logic_vector(7 downto 0);
        ALUop: in std_logic_vector(3 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        ALUout: out std_logic;
        ALU_Answer: out std_logic_vector(7 downto 0);
        zflg: out std_logic);
        
end ALU_Final;

architecture arch of ALU_final is
  
begin

  process(Rx,Ry,ALUop,Sel)

     variable ALU_A: unsigned(7 downto 0);
     variable ALU_Z: unsigned(8 downto 0);
     variable Rx_hold : std_logic_vector (8 downto 0):="000000000";
     variable Ry_hold : std_logic_vector (8 downto 0):="000000000";
    begin
    Rx_hold := Rx+"000000000";
    Ry_hold := Ry+"000000000";
    
   if (ALUop ="0000")  --PC+1
      then ALUout<= '1';
  
  elsif (ALUop="0001") then --Add Immediate
    ALU_Z := unsigned(Rx_hold) + unsigned(Ry_hold); 
    ALUout<='0';
    if (ALU_Z(8) = '1') then
      zflg <='1';
    else zflg<='0';
    end if;
    ALU_Answer <=std_logic_vector(ALU_Z(7 downto 0));
     
  elsif(ALUop="0010") then
      
      if (sel ="0000") then --Add
          ALU_Z := unsigned(Rx_hold)+ unsigned(Ry_hold);
          if (ALU_Z(8) = '1') then
          zflg<='1';
          else zflg<='0';
          end if;
          ALU_Answer <=std_logic_vector(ALU_Z(7 downto 0));
           ALUout<='0';
           
      elsif(sel="0001") then --Subtract
        ALU_A := unsigned(Rx) - unsigned(Ry);
        ALU_Answer <=std_logic_vector(ALU_A);
         ALUout<='0';
         zflg<='0';
      end if;
  
  elsif (ALUop = "0011") then
      
      if (sel ="0000") then --Increment
        ALU_A := unsigned(Rx) + 1;
        ALU_Answer <=std_logic_vector(ALU_A);
        ALUout<='0';
        zflg<='0';
      elsif(sel="0001") then --Decrement
        ALU_A := unsigned(Rx) - 1;
        ALU_Answer <=std_logic_vector(ALU_A);
        ALUout<='0';
        zflg<='0';
      end if;
      
  elsif (ALUop = "0100") then
  
      if (sel="0000") then --Shift Left
        ALU_A := unsigned(Rx) sll to_integer(unsigned(Ry));
        ALUout<='0';
        ALU_Answer<= std_logic_vector(ALU_A);
        zflg<='0';
        
      elsif(sel="0001") then --Shift Right
        ALU_A := unsigned(Rx) srl to_integer(unsigned(Ry));
        ALUout<='0';
        ALU_Answer <= std_logic_vector(AlU_A);
        zflg <='0';
      end if;
        
  elsif(ALUop = "0101") then
    
      if (sel="0000") then --Logical Not
        ALU_Answer<= std_logic_vector(not(Rx));
        ALUout<='0'; 
        zflg<='0';
      
      elsif(sel="0001") then --Logical NOR
        ALU_Answer <= std_logic_vector(Rx nor Ry);
         ALUout<='0';
         zflg<='0';
        
      elsif(sel="0010") then --Logical NAND
         ALU_Answer <= std_logic_vector(Rx NAND Ry);
        ALUout<='0';
        zflg <='0'; 
      
      elsif(sel="0011") then --Logical XOR
        ALU_Answer <= std_logic_vector(Rx XOR Ry);
        ALUout<='0';
        zflg <='0';
        
      elsif(sel="0100") then --Logical AND
        ALU_Answer <= std_logic_vector(Rx AND Ry);
        ALUout<='0';
        zflg <='0';
        
      elsif(sel="0101") then --Logical OR
        ALU_Answer<= std_logic_vector(Rx OR Ry);
        ALUout<='0';
        zflg <='0';
        
      elsif(sel="0110") then --Clear
        ALU_Answer<= "00000000";
        ALUout<='0';
        zflg <='0';
        
      elsif(sel="0111") then --Set
        ALU_Answer<="11111111";
        ALUout<='0';
        zflg <='0';
        
      elsif(sel="1111") then
        if (Rx<Ry) then
          ALU_Answer<= "11111111";
          ALUout<='0';
          zflg <='0';
        else 
          ALU_Answer <= "00000000";
          ALUout <= '0';
          zflg <='0';
        end if;
      
      elsif(sel="1000")then
      ALU_Answer<=Rx;
      zflg <='0';
    end if;
  elsif ( ALUop = "1101" ) then
    if ( Rx = "00000000" ) then
      zflg <= '1';
    else 
      zflg <= '0';
    end if;
  elsif ( ALUop = "1110" ) then
    if ( Rx /= "00000000" ) then
      zflg <= '1';
    else 
      zflg <= '0';
    end if;
  else null;
  end if; 
   
end process;
end arch;