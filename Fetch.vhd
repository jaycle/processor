LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
Use work.all;

entity fetch is
  port( offset,jump_A : in std_logic_vector(7 downto 0);
        clk,branch_en,jump_en: in std_logic;
        instruction: out std_logic_vector(15 downto 0)
 --       Mnemonics: out string(7 downto 1)
      );
end entity;
    
architecture Behav of fetch is

      constant add_w: integer:=8;
      constant depth: integer:=2**8;
      constant width: integer:=16;

--	signal instruction_s: std_logic_vector(15 downto 0);
      signal Address : std_logic_vector(7 downto 0);
   
begin
          
    PC1 : entity work.PC(behav)
    	port map(
        	jump_en => jump_en,
          	branch_en => branch_en, 
		clk => clk,
          	jump => jump_A,
          	offset=>offset,
          	addr=>address);
        
	IMEM1 : entity work.IMEM(imem_arch)
        generic Map(add_w, depth, width)
        port map(
        	Addr => address,
          	Instr => instruction);  
        
--  Name: process(instruction_s)
--  begin
--    instruction <= instruction_s;
--    
--   case(instruction_s(15 downto 12)) is
--      when "0000" => Mnemonics <= "NOP";
--      when "0001" => Mnemonics <= "ADDI";
--      when "0010" => 
--        if ( instruction_s(11 downto 8) = "0000" ) then
--          Mnemonics <= "ADD";
--        elsif ( instruction_s(11 downto 8) = "0001" ) then
--          Mnemonics <= "SUB";
--        else 
--          Mnemonics <= "Unknown";
--        end if;
--      when "0011" => 
--        if ( instruction_s(11 downto 8) = "0000" ) then
--          Mnemonics <= "INC";
--        elsif ( instruction_s(11 downto 8) = "0001" ) then
--          Mnemonics <= "DEC";
--        else 
--          Mnemonics <= "Unknown";
--        end if;
--     when "0100" => 
--        if ( instruction_s(11 downto 8) = "0000" ) then
--          Mnemonics <= "SHL";
--        elsif ( instruction_s(11 downto 8) = "0001" ) then
--          Mnemonics <= "SHR";
--        else 
--          Mnemonics <= "Unknown";
--        end if;
--      when "0101" => 
--        if ( instruction_s(11 downto 8) = "0000" ) then
--          Mnemonics <= "NOT";
--        elsif ( instruction_s(11 downto 8) = "0001" ) then
--          Mnemonics <= "NOR";      
--        elsif ( instruction_s(11 downto 8) = "0010" ) then
--            Mnemonics <= "NAND";
--        elsif ( instruction_s(11 downto 8) = "0011" ) then
--          Mnemonics <= "XOR";
--        elsif ( instruction_s(11 downto 8) = "0100" ) then
--          Mnemonics <= "AND";
--        elsif ( instruction_s(11 downto 8) = "0101" ) then
--          Mnemonics <= "OR";
--        elsif ( instruction_s(11 downto 8) = "0110" ) then
--          Mnemonics <= "CLR";
--        elsif ( instruction_s(11 downto 8) = "0111" ) then
--          Mnemonics <= "SET";
--        elsif ( instruction_s(11 downto 8) = "1111" ) then
--          Mnemonics <= "SLT";
--        elsif ( instruction_s(11 downto 8) = "1000" ) then
--          Mnemonics <= "MOV";
--        else 
--          Mnemonics <= "Unknown";
--        end if;
--      when "0111" => Mnemonics <= "EI";
--      when "1000" => Mnemonics <= "LDI";
--      when "1001" => Mnemonics <= "STRI";
--      when "1010" => Mnemonics <= "LDR";
--      when "1011" => Mnemonics <= "STRR";
--      when "1100" => Mnemonics <= "JMP";
--      when "1101" => Mnemonics <= "BZ";
--      when "1110" => Mnemonics <= "BNZ";
--      when "1111" => Mnemonics <= "RETI";
--      
--      when others => Mnemonics <= "Unknown";
--    end case;
--  end process;
          
end architecture;