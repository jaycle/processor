
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity Decoder is
  Port (      --Inputs--
          Instruction : in Std_logic_vector(15 downto 0);
          InterruptLines : in std_logic_vector(3 downto 0);
          Zflg : in std_logic;
          clk : in std_logic;
                  --Outputs--
          interrupts : out std_logic;
          clock_en : out std_logic;
          branch : out std_logic;
          ALU_op_mux_e : out std_logic;
          jump: out std_logic;
          wr_e : out std_logic;
          Register_Indirect : out std_logic;
          IM : out std_logic;
          InterruptLine: out std_logic_vector(1 downto 0);
          ALUop : out std_logic_vector(3 downto 0);
          Sel : out std_logic_vector(3 downto 0);
          wr : out std_logic_vector(3 downto 0); 
          Rx : out std_logic_vector(3 downto 0);
          Ry : out std_logic_vector (3 downto 0); 
          IM_data: out std_logic_vector(7 downto 0));
end Decoder; 


architecture Arch of Decoder is
  
COMPONENT REG IS
  GENERIC (
    W : integer );
  PORT (
    D:   IN std_logic_vector(W-1 DOWNTO 0);
    Clk: IN std_logic;
    Q:   OUT std_logic_vector(W-1 DOWNTO 0) );
END COMPONENT;
FOR ALL: REG USE ENTITY WORK.REG(REGISTER_ARCH);


signal internalState : std_logic_vector(2 downto 0) := "000";
signal enabledInterruptLines : std_logic_vector(3 downto 0) := "0000";
signal interruptLine_S : std_logic_vector(1 downto 0) := "00";
signal interruptClockCount: std_logic_vector(4 downto 0) := "00000";
signal interruptThreadActive: std_logic := '0';
signal wr_addr, WriteAddr1, WriteAddr2: std_logic_vector(3 downto 0);
signal clock_enS: std_logic:='0';
signal HazDelay : std_logic;


begin 
  
R1: REG generic map(
          W => 4 )
        port map(
          D => wr_addr,
          Clk => clk,
          Q => WriteAddr1 );
          
R2: REG generic map(
          W => 4 )
        port map(
          D => WriteAddr1,
          Clk => clk,
          Q => WriteAddr2 );
          
  wr <= wr_addr;
  clock_en <= clock_enS;

process(clk, Instruction)
variable op_code : std_logic_vector(3 downto 0);
variable sel_s : std_logic_vector(3 downto 0);
variable temp : std_logic_vector(4 downto 0);
variable interrupt : std_logic := '0'; 
variable RxV, RyV: std_logic_vector(3 downto 0);
variable Hazard: std_logic;

variable internalStateV: std_logic_vector(2 downto 0);

begin
  op_code:= instruction(15 downto 12); --Bits 15 to 12 become the op_code to use in the if statements
  sel_s := instruction (11 downto 8); --Bits 11 to 8 become the select line to use in the if statements as well
  internalStateV := internalState;
  
--if ( clk'event and clk = '1' ) then

if ( ((InterruptLines and enabledInterruptLines) /= "0000") and interruptThreadActive /= '1' and rising_edge(clk) ) then
  internalStateV := "011";
  interruptThreadActive <= '1';
    
  if ( (InterruptLines and "0001") /= "0000" ) then
    InterruptLine_S <= "00";
  elsif ( (InterruptLines and "0010") /= "0000" ) then
    InterruptLine_S <= "01";
  elsif ( (InterruptLines and "0100") /= "0000" ) then
    InterruptLine_S <= "10";
  elsif ( (InterruptLines and "1000") /= "0000" ) then
    InterruptLine_S <= "11";
  end if;
end if;

--clock_enS <= '1';
    
if (internalStateV = "000" and Instruction'event ) then
  clock_enS <= '1';
  interrupts <= '0';
  
  if op_code = "0000" then --NO Operation
          branch <= '0'; --Branch is the enable for the PC to do the branch
          jump<='0'; --Jump select line, connects to the MEMADDR
          wr_e<='0'; --Enables the Write for the register bank
          Register_Indirect<='0'; --Direct which data goes into the Data Memory
          IM <= '0';--Turns on to enable the add Immediate 
          ALUop <= instruction(15 downto 12); --OP code 
          Sel <= instruction(11 downto 8); --Select Line
          wr_addr <= instruction(7 downto 4); --The location where the register is going to be written on
          RyV := instruction(3 downto 0); --The address of RX
          RxV := instruction (7 downto 4); --The Address of Ry
          IM_data <= instruction(7 downto 0); --The Data for add immediate and the location for the DMEM
          interrupt:='0'; --Will enable the interrupts
          ALU_op_mux_e<='0'; --enable mux for WrBk
          internalStateV := "000";
          Hazard := '0';
 
  
  elsif op_code = "0001" then --Add Immediate operation
    branch <= '0'; 
    jump<='0'; 
    wr_e<='1'; 
    Register_Indirect<='0'; 
    IM <= '1';
    ALUop <= instruction(15 downto 12);
    Sel <= instruction(11 downto 8);
    wr_addr <= instruction(11 downto 8);
    RxV := instruction(11 downto 8);
    RyV := instruction (3 downto 0);
    IM_data <= instruction(7 downto 0); 
    interrupt:='0';
    ALU_op_mux_e<='0';
    internalStateV := "000";
    if ( RxV = WriteAddr1 or RxV = wr_addr ) then
      Hazard := '1';
    else
      Hazard := '0';
    end if;
  
  elsif op_code = "0010" then --Add and Subtract  
          branch <= '0';
          jump<='0';
          wr_e<='1';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0'; 
          ALU_op_mux_e<='0';
          internalStateV := "000";
          if ( RxV = WriteAddr1 or RxV = wr_addr or RyV = WriteAddr1 or RyV = wr_addr ) then
            Hazard := '1';
          else
            Hazard := '0';
          end if;
    
  
  elsif op_code = "0011" then --Increment/Decrement
          branch <= '0';
          jump<='0';
          wr_e<='1';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e<='0';
          internalStateV := "000";
          if ( RxV = WriteAddr1 or RxV = wr_addr ) then
            Hazard := '1';
          else
            Hazard := '0';
          end if;
  
    
  elsif op_code = "0100" then --Shifts
          branch <= '0';
          jump<='0';
          wr_e<='1';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e<='0';
          internalStateV := "000";
          if ( RxV = WriteAddr1 or RxV = wr_addr or RyV = WriteAddr1 or RyV = wr_addr ) then
            Hazard := '1';
          else
            Hazard := '0';
          end if;
    
  elsif op_code = "0101" then --Logical and Clear/Set/Move statments
          if ( sel_s = "1000" ) then --Move statment
            branch <= '0';
            jump<='0';
            wr_e<='1';
            Register_Indirect<='0'; 
            IM <= '0';
            ALUop <= instruction(15 downto 12);
            Sel <= instruction(11 downto 8);
            wr_addr <= instruction(3 downto 0);
            RyV := instruction(3 downto 0);
            RxV := instruction (7 downto 4);
            IM_data <= instruction(7 downto 0);
            interrupt:='0';
            ALU_op_mux_e<='0';
            internalStateV := "000";
            if ( RxV = WriteAddr1 or RxV = wr_addr or RyV = WriteAddr1 or RyV = wr_addr ) then
              Hazard := '1';
            else
              Hazard := '0';
            end if;
              
          else 
            branch <= '0';
            jump<='0';
            wr_e<='1';
            Register_Indirect<='0'; 
            IM <= '0';
            ALUop <= instruction(15 downto 12);
            Sel <= instruction(11 downto 8);
            wr_addr <= instruction(7 downto 4);
            RyV := instruction(3 downto 0);
            RxV := instruction (7 downto 4);
            IM_data <= instruction(7 downto 0);
            interrupt:='0';
            ALU_op_mux_e<='0';
            internalStateV := "000";
            if ( instruction(11 downto 8) = "0000" and (RxV = WriteAddr1 or RxV = wr_addr) ) then
              Hazard := '1';
            elsif ( instruction(11 downto 8) /= "0110" and instruction(11 downto 8) /= "0111" ) then
              if ( RxV = WriteAddr1 or RxV = wr_addr or RyV = WriteAddr1 or RyV = wr_addr ) then
                Hazard := '1';
              else
                Hazard := '0';
              end if;
            else
              Hazard := '0';
            end if;
          end if;
          
  elsif op_code ="0111" then --Enable Interrupts 
          branch <= '0'; --Branch is the enable for the PC to do the branch
          jump<='0'; --Jump select line, connects to the MEMADDR
          wr_e<='0'; --Enables the Write for the register bank
          Register_Indirect<='0'; --Direct which data goes into the Data Memory
          IM <= '0';--Turns on to enable the add Immediate 
          ALUop <= "0000"; --OP code 
          Sel <= "0000"; --Select Line
          wr_addr <= "0000"; --The location where the register is going to be written on
          RyV := "0000"; --The address of RX
          RxV := "0000"; --The Address of Ry
          IM_data <= "00000000"; --The Data for add immediate and the location for the DMEM
          ALU_op_mux_e<='0'; --enable mux for WrBk
          enabledInterruptLines <= InterruptLines;
          internalStateV := "000";
          Hazard := '0';

  elsif op_code ="1000" then --Load Indirect 
          branch <= '0';
          jump<='0';
          wr_e<='1';
          Register_Indirect<='1'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e <='1';
          internalStateV := "000";
          if ( RyV = WriteAddr1 or RyV = wr_addr ) then
            Hazard := '1';
          else 
            Hazard := '0';
          end if;
  
  elsif op_code ="1001" then --Store Indirect
          branch <= '0';
          jump<='0';
          wr_e<='0';
          Register_Indirect<='1'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0); 
          interrupt:='0';
          ALU_op_mux_e<= '0';
          internalStateV := "000";
          if ( RxV = WriteAddr1 or RxV = wr_addr or RyV = WriteAddr1 or RyV = wr_addr ) then
            Hazard := '1';
          else
            Hazard := '0';
          end if;
  
  elsif op_code = "1010" then --Load Register
    branch <= '0';
    jump<='0';
    wr_e<='1';
    Register_Indirect<='0'; 
    IM <= '0';
    ALUop <= instruction(15 downto 12);
    Sel <= instruction(11 downto 8);
    wr_addr <= instruction(11 downto 8);
    RxV := instruction(11 downto 8);
    RyV := instruction (3 downto 0);
    IM_data <= instruction(7 downto 0);
    interrupt:='0';
    ALU_op_mux_e <='1';
    internalStateV := "000";
    Hazard := '0';
  
  elsif op_code = "1011" then  --Store Register
    branch <= '0';
    jump<='0';
    wr_e<='0';
    Register_Indirect<='0'; 
    IM <= '0';
    ALUop <= instruction(15 downto 12);
    Sel <= instruction(11 downto 8);
    wr_addr <= instruction(11 downto 8);
    RxV := instruction(11 downto 8);
    RyV := instruction (3 downto 0);
    IM_data <= instruction(7 downto 0);
    interrupt:='0';
    ALU_op_mux_e <='0';
    internalStateV := "000";
    if ( RxV = WriteAddr1 or RxV = wr_addr ) then
      Hazard := '1';
    else
      Hazard := '0';
    end if;
    
  elsif op_code ="1100" then --Jump operation
          clock_enS <= '0';
    
          branch <= '0';
          jump<='1';
          wr_e<='0';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e <='0';
          internalStateV := "001";
          Hazard := '0';
          
  elsif op_code ="1101" then --Branch if Zero operation
          clock_enS <= '0';
          
          branch <= '0';
          jump<='0';
          wr_e<='0';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e <='0';
          internalStateV := "010";
          if ( RxV = WriteAddr1 or RxV = wr_addr ) then
            Hazard := '1';
          else
            Hazard := '0';
          end if;
          
    
    elsif op_code ="1110" then --Branch if not zero operation
          clock_enS <= '0';
      
          branch <= '0';
          jump<='0';
          wr_e<='0';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e <='0';
          internalStateV := "010";
          if ( RxV = WriteAddr1 or RxV = wr_addr ) then
            Hazard := '1';
          else
            Hazard := '0';
          end if;
  
    elsif op_code ="1111" and InterruptThreadActive = '1' then --Return from Interrupt
          branch <= '0';
          jump<='0';
          wr_e<='0';
          Register_Indirect<='0'; 
          IM <= '0';
          ALUop <= instruction(15 downto 12);
          Sel <= instruction(11 downto 8);
          wr_addr <= instruction(7 downto 4);
          RyV := instruction(3 downto 0);
          RxV := instruction (7 downto 4);
          IM_data <= instruction(7 downto 0);
          interrupt:='0';
          ALU_op_mux_e <='0';
          internalStateV := "100";
          Hazard := '0';
    end if;
    
    if ( Hazard = '1' ) then  --------------------HAZARDS--------------------
      clock_enS <= '0';
      HazDelay <= '1';
      branch <= '0';
      jump <= '0';
      wr_e <= '0';
      Register_Indirect <= '0';
      IM <= '0'; 
      ALUop <= "0000"; 
      Sel <= "0000";
      wr_addr <= "0000";
      RxV := "0000";
      RyV := "0000";
      IM_data <= "00000000";
      ALU_op_mux_e <= '0';
    else
      clock_enS <= '1';
      HazDelay<='0';
    end if;
          
elsif ( internalStateV = "001" and rising_edge(clk) ) then --JUMP
  clock_enS <= '1';
  interrupts <= '0';
  
  branch <= '0';
  jump<='0';
  wr_e<='0';
  Register_Indirect<='0'; 
  IM <= '0';
  ALUop <= "0000";
  Sel <= "0000";
  wr_addr <= "0000";
  RyV := "0000";
  RxV := "0000";
  IM_data <= "00000000";
  interrupt:='0';
  ALU_op_mux_e <='0';
  internalStateV := "111";
  
elsif ( internalStateV = "010" and rising_edge(clk) ) then --BRANCH
  clock_enS <= '1';
  interrupts <= '0';
  
  branch <= Zflg;
  jump<='0';
  wr_e<='0';
  Register_Indirect<='0'; 
  IM <= '0';
  ALUop <= "0000";
  Sel <= "0000";
  wr_addr <= "0000";
  RyV := "0000";
  RxV := "0000";
  IM_data <= instruction(7 downto 0);
  interrupt:='0';
  ALU_op_mux_e <='0';
  internalStateV := "111"; 

elsif ( internalStateV = "011" and rising_edge(clk) ) then --INTERRUPTS
  clock_enS <= '0';
  
  if ( interruptClockCount < "00010" ) then
    branch <= '0';
    jump <= '0';
    wr_e <= '0';
    Register_Indirect <= '0';
    IM <= '0'; 
    ALUop <= "0000"; 
    Sel <= "0000";
    wr_addr <= "0000";
    RyV := "0000";
    RxV := "0000";
    IM_data <= "00000000";
    ALU_op_mux_e <= '0';
    
    interruptClockCount <= interruptClockCount + "00001"; 
  elsif ( interruptClockCount < "10010" ) then
    interrupts <= '1';
    
    branch <= '0';
    jump <= '0';
    wr_e <= '0';
    Register_Indirect <= '0';
    IM <= '0'; 
    ALUop <= "0000"; 
    Sel <= "0000";
    wr_addr <= "0000";
    temp := interruptClockCount-"00010";
    RxV := temp(3 downto 0);
    temp := interruptClockCount-"00001";
    RyV := temp(3 downto 0);
    IM_data <= "00000000";
    ALU_op_mux_e <= '0';
    
    interruptClockCount <= interruptClockCount + "00010";
    
--    if ( interruptClockCount = "01101" ) then
--      clock_enS <= '1';
--    end if;
  else 
    internalStateV := "000";
    interrupts <= '0';
    clock_enS <= '1';
    interruptClockCount <= "00000";
  end if;
  
elsif ( internalStateV = "100" and rising_edge(clk) ) then --RETURN FROM INTERRUPTS
  clock_enS <= '1';
  
  if ( interruptClockCount < "00010" ) then
    branch <= '0';
    jump <= '0';
    wr_e <= '1';
    Register_Indirect <= '0';
    IM <= '0'; 
    ALUop <= "0000"; 
    Sel <= "0000";
    wr_addr <= "0000";
    RyV := "0000";
    RxV := "0000";
    IM_data <= "00000000";
    ALU_op_mux_e <= '0';
    
    interruptClockCount <= interruptClockCount + "00001"; 
  elsif ( interruptClockCount < "10010" ) then
    interrupts <= '1';
    
    branch <= '0';
    jump <= '0';
    wr_e <= '1';
    Register_Indirect <= '0';
    IM <= '0'; 
    ALUop <= "0000"; 
    Sel <= "0000";
    wr_addr <= "0000";
    temp := interruptClockCount-"00010";
    RxV := temp(3 downto 0);
    IM_data <= "00000000";
    ALU_op_mux_e <= '0';
    
    interruptClockCount <= interruptClockCount + "00001";
    
--    if ( interruptClockCount = "10000" ) then
--      clock_enS <= '1';
--    end if;
  else 
    internalStateV := "000";
    interrupts <= '0';
    clock_enS <= '1';
    interruptClockCount <= "00000";
    interruptThreadActive <= '0';
  end if;
elsif ( internalState = "111" and rising_edge(clk) ) then
  clock_enS <= '1';
  interrupts <= '0';
  
  branch <= '0';
  jump<='0';
  wr_e<='0';
  Register_Indirect<='0'; 
  IM <= '0';
  ALUop <= "0000";
  Sel <= "0000";
  wr_addr <= "0000";
  RyV := "0000";
  RxV := "0000";
  IM_data <= "00000000";
  interrupt:='0';
  ALU_op_mux_e <='0';
  internalStateV := "000";
end if;
--end if;

  internalState <= internalStateV;
  Ry <= RyV;
  Rx <= RxV;
--end if;
--wait on clk;
end process;

--InterruptProcedure: process(InterruptLines)
--variable internalState: std_logic_vector(2 downto 0) := "000";
--begin
--  if ( ((InterruptLines and enabledInterruptLines) /= "0000") and internalState /= "011" ) then
--    internalState := "011";
--    
--    if ( (InterruptLines and "0001") /= "0000" ) then
--      InterruptLine_S <= "00";
--    elsif ( (InterruptLines and "0010") /= "0000" ) then
--      InterruptLine_S <= "01";
--    elsif ( (InterruptLines and "0100") /= "0000" ) then
--      InterruptLine_S <= "10";
--    elsif ( (InterruptLines and "1000") /= "0000" ) then
--      InterruptLine_S <= "11";
--    end if;
--  end if;
--end process;

InterruptLineUpdate: process(InterruptLine_S)
begin
  InterruptLine <= InterruptLine_S;
end process;

End Arch; 