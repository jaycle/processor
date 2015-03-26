LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
Use work.all;

entity fetch is
  port( interrupt_A,offset,jump_A : in std_logic_vector(7 downto 0);
        clk, clk_en, interrupt_en,branch,jump: in std_logic;
        PCOut: out std_logic_vector(7 downto 0);
        instruction: out std_logic_vector(15 downto 0)
        --Mnemonics: out string(7 downto 1)
      );
    end entity;
    
  architecture Behav of fetch is
   
      component Mux is 
         Port(   
          selectL : in std_logic;
          Min1 : in std_logic_vector(7 downto 0); --Select if SelectL is low
          Min2 : in std_logic_vector(7 downto 0); --Select if SelectL is High
          muxout : out std_logic_vector(7 downto 0)
          ); end component;
        
      component latch is
      port( in_addr : in std_logic_vector (7 downto 0);
            clk : in std_logic;
            out_addr, pc_addr : out std_logic_vector (7 downto 0)
             );
      end component;
      
      component IMEM is
        GENERIC (
           S : integer;W:integer);
        PORT (
             Addr:  IN std_logic_vector(S-1 DOWNTO 0);
             Instr: OUT std_logic_vector(W-1 DOWNTO 0) );
      end component; 
     
      component PC is
          port( 
          jump_en, branch_en : in std_logic; 
          wr_addr, jump, offset : in  std_logic_vector (7 downto 0);
          addr : out std_logic_vector (7 downto 0));  
      end component;
    
      constant S: integer:=8;
      constant W: integer:=16;
      signal mux_to_Latch : std_logic_vector(7 downto 0);
      signal reg_to_IMEM : std_logic_vector(7 downto 0);
      signal addr_s,pc_addr_S : std_logic_vector(7 downto 0);
      signal jump_en: std_logic;
      --signal instruction_s: std_logic_vector(15 downto 0);
      signal clk_f: std_logic;
    for all : mux use entity work.mux_2_1(Behavioral);
    for all : latch use entity work.latch(Behav);
    for all : IMEM use entity work.IMEM(IMEM_arch);
     
    begin
      
      --process
      --begin
        --if ( jump_en = 'U' ) then
         -- jump_en <= '0';
        --else 
         -- jump_en <= jump;
        --end if;  
        
        --wait on jump;
      --end process;
        
      clk_f <= clk and clk_en;
      
      mux_pc_Mem : Mux 
            port map( 
            SelectL => interrupt_en, --Selector
            Min1=> addr_s , --select if low
            Min2=> interrupt_A, --select if high
            Muxout=> mux_to_Latch
          );
          
      mem_A : latch
        port map(
          in_addr => mux_to_latch,
          clk => clk,
          out_addr => reg_to_IMEM,
          pc_addr => pc_addr_s
          );
          
      PCOut <= reg_to_IMEM;
          
      PC1 : PC 
        port map(
          jump_en => jump,
          branch_en => branch, 
          wr_addr => pc_addr_s,
          jump => jump_A,
          offset=>offset,
          addr=>addr_s);
        
      IMEM1 : IMEM
        generic Map(S=>S,W=>W)
        port map(
          Addr => reg_to_IMEM,
          Instr => instruction);  
        
  --Name: process(instruction_s)
  --begin
  --  instruction <= instruction_s;
    
  -- case(instruction_s(15 downto 12)) is
  --    when "0000" => Mnemonics <= "NOP";
  --    when "0001" => Mnemonics <= "ADDI";
  --    when "0010" => 
  --      if ( instruction_s(11 downto 8) = "0000" ) then
  --        Mnemonics <= "ADD";
  --      elsif ( instruction_s(11 downto 8) = "0001" ) then
  --        Mnemonics <= "SUB";
  --      else 
  --        Mnemonics <= "Unknown";
  --      end if;
  --    when "0011" => 
  --      if ( instruction_s(11 downto 8) = "0000" ) then
  --        Mnemonics <= "INC";
  --      elsif ( instruction_s(11 downto 8) = "0001" ) then
  --        Mnemonics <= "DEC";
  --      else 
  --        Mnemonics <= "Unknown";
  --      end if;
  --   when "0100" => 
  --      if ( instruction_s(11 downto 8) = "0000" ) then
  --        Mnemonics <= "SHL";
  --      elsif ( instruction_s(11 downto 8) = "0001" ) then
  --        Mnemonics <= "SHR";
  --      else 
  --        Mnemonics <= "Unknown";
  --      end if;
  --    when "0101" => 
  --      if ( instruction_s(11 downto 8) = "0000" ) then
  --        Mnemonics <= "NOT";
  --      elsif ( instruction_s(11 downto 8) = "0001" ) then
  --        Mnemonics <= "NOR";      
  --      elsif ( instruction_s(11 downto 8) = "0010" ) then
  --          Mnemonics <= "NAND";
  --      elsif ( instruction_s(11 downto 8) = "0011" ) then
  --        Mnemonics <= "XOR";
  --      elsif ( instruction_s(11 downto 8) = "0100" ) then
  --        Mnemonics <= "AND";
  --      elsif ( instruction_s(11 downto 8) = "0101" ) then
  --        Mnemonics <= "OR";
  --      elsif ( instruction_s(11 downto 8) = "0110" ) then
  --        Mnemonics <= "CLR";
  --      elsif ( instruction_s(11 downto 8) = "0111" ) then
  --        Mnemonics <= "SET";
  --      elsif ( instruction_s(11 downto 8) = "1111" ) then
  --        Mnemonics <= "SLT";
  --      elsif ( instruction_s(11 downto 8) = "1000" ) then
  --        Mnemonics <= "MOV";
  --      else 
  --        Mnemonics <= "Unknown";
  --      end if;
  --    when "0111" => Mnemonics <= "EI";
  --    when "1000" => Mnemonics <= "LDI";
  --    when "1001" => Mnemonics <= "STRI";
  --    when "1010" => Mnemonics <= "LDR";
  --    when "1011" => Mnemonics <= "STRR";
  --    when "1100" => Mnemonics <= "JMP";
  --    when "1101" => Mnemonics <= "BZ";
  --    when "1110" => Mnemonics <= "BNZ";
  --    when "1111" => Mnemonics <= "RETI";
      
  --    when others => Mnemonics <= "Unknown";
  --  end case;
  --end process;
          
end architecture;