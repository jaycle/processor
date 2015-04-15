library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.ALL;
Use Ieee.std_logic_unsigned.all;

entity FinalPipeline is
  port (
    clk: in std_logic;
    InterruptLines: in std_logic_vector(3 downto 0) );
end entity;

architecture Arch of FinalPipeline is
  
component Fetch is
  port( interrupt_A,offset,jump_A : in std_logic_vector(7 downto 0);
        clk, clk_en, interrupt_en,branch,jump: in std_logic;
        PCOut: out std_logic_vector(7 downto 0);
        instruction: out std_logic_vector(15 downto 0)
      );
end component;
FOR ALL: Fetch use entity work.fetch(Behav);

component Decoder is
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
          IM_data: out std_logic_vector(7 downto 0) );
end component;
FOR ALL: Decoder use entity work.Decoder(arch);

component Execute is
  
  port ( 
          wr_e : in std_logic;
          Register_Indirect: in std_logic;
          IM: in std_logic;
          ALUop : in std_logic_vector(3 downto 0);
          Sel : in std_logic_vector (3 downto 0);
          wr : in std_logic_vector(3 downto 0);
          Rx : in std_logic_vector (3 downto 0);
          Ry : in std_logic_vector(3 downto 0);
          IM_data : in std_logic_vector(7 downto 0);
          WrBk : in std_logic_vector(7 downto 0);
          Interrupts : in std_logic;
          IrData : in std_logic_vector(7 downto 0);
          RxD, RyD: out std_logic_vector(7 downto 0);
          ALUout : out std_logic;
          WriteData : out std_logic_vector(7 downto 0);
          dAddr : out std_logic_vector(7 downto 0);
          ALU_Answer : out std_logic_vector(7 downto 0);
          Zflg : out std_logic
          );
          
    
end component;
FOR ALL: Execute use entity work.Execute(arch);

component WriteBack is
  
  port (
          ALUop: in std_logic_vector(3 downto 0);
          writeData :in std_logic_vector(7 downto 0);
          location_address : in std_logic_vector(7 downto 0);
          ALU_op_mux_e : in std_logic;
          ALU_Answer : in std_logic_vector(7 downto 0);
          wr_BK : out std_logic_vector(7 downto 0)
        );
end component;
FOR ALL: WriteBack use entity work.WriteBack(arch);

component REG IS
  GENERIC (
    W : integer );
  PORT (
    D:   IN std_logic_vector(W-1 DOWNTO 0);
    Clk: IN std_logic;
    Q:   OUT std_logic_vector(W-1 DOWNTO 0) );
END component;
FOR ALL: REG use entity work.REG(REGISTER_ARCH);

component InterruptHandler IS
  GENERIC (
    S : integer;
    W : integer );
  PORT (
    Rdx, Rdy:       IN std_logic_vector(S-1 DOWNTO 0);
    Rxi, Ryi:       IN std_logic_vector(W-1 DOWNTO 0);
    PCi:            IN std_logic_vector(W-1 DOWNTO 0);
    InterruptLine:  IN std_logic_vector(1 downto 0);
    En:             IN std_logic;
    Ro:             OUT std_logic_vector(W-1 DOWNTO 0);
    PCo:            OUT std_logic_vector(W-1 DOWNTO 0) );
END component;
FOR ALL: InterruptHandler use entity work.InterruptHandler(Arch);

--------------------Fetch Signals--------------------
signal instr_reg: std_logic_vector(15 downto 0);
signal currentPC: std_logic_vector(7 downto 0);
signal jump_en, branch_en: std_logic;
signal interrupts_en, clk_en: std_logic;
signal jump_a, branch_a, interrupt_a: std_logic_vector(7 downto 0);
--signal Mnemonics: string(3 downto 0);

--------------------Decoder Signals--------------------
signal reg_instr: std_logic_vector(15 downto 0);
signal ALU_DMem_Mux_reg1, wr_e_reg1, Register_indirect_reg, IM_Ry_reg: std_logic;
signal interruptLine_S: std_logic_vector(1 downto 0);
signal ALUOp_reg, Sel_reg, wr_addr_reg1, Rdx_reg, Rdy_reg: std_logic_vector(3 downto 0);
signal IM_Data_reg: std_logic_vector(7 downto 0);

--------------------Execute Signals--------------------
signal reg1_wr_e_reg2, reg2_wr_e: std_logic;
signal reg_register_indirect, reg_IM_Ry: std_logic;
signal reg1_wr_addr_reg2, reg2_wr_addr: std_logic_vector(3 downto 0);
signal reg_ALUOp, reg_Sel, reg_Rdx, reg_Rdy: std_logic_vector(3 downto 0);
signal reg_IM_Data: std_logic_vector(7 downto 0);
signal wrbk: std_logic_vector(7 downto 0);
signal aluout, zflg: std_logic;
signal WriteData_reg, dAddr_reg, ALUAnswer_reg: std_logic_vector(7 downto 0);
signal IrDataS, RxDS, RyDS: std_logic_vector(7 downto 0);

--------------------WriteBack Signals--------------------
signal reg1_ALU_DMem_Mux_reg2, reg2_ALU_DMem_Mux: std_logic;
signal reg2_ALUOp: std_logic_vector(3 downto 0);
signal reg_WriteData, reg_locationAddress, reg_ALUAnswer: std_logic_vector(7 downto 0);

---------------------------------------------------------
signal TempSIn1, TempSOut1: std_logic_vector(11 downto 0);
signal TempSOut2: std_logic_vector(9 downto 0);
signal TempDEIn, TempDEOut: std_logic_vector(19 downto 0);
signal TempEWIn, TempEWOut: std_logic_vector(23 downto 0);
signal clk_f: std_logic;

begin

-------------------------Fetch Port Map-------------------------

F1: Fetch port map (
                clk => clk,
                clk_en => clk_en,
                interrupt_A => interrupt_a,
                offset => IM_data_reg,
                jump_A => IM_data_reg,
                interrupt_en => interrupts_en,
                branch => branch_en,
                jump => jump_en,
                PCOut => currentPC,
                instruction => instr_reg );
                
--------------------Fetch To Decode Register--------------------
                
--clk_f <= clk and clk_en;               
                
F_REG_D: REG generic map ( W => 16 )
             port map (
                CLK => clk,
                D => instr_reg,
                Q => reg_instr );
                
------------------------Decoder Port Map------------------------
                
D1: Decoder port map (
                Instruction => reg_instr,
                interrupts => interrupts_en,
                clock_en => clk_en,
                branch => branch_en,
                ALU_op_mux_e => ALU_DMem_Mux_reg1,
                jump => jump_en,
                wr_e => wr_e_reg1,
                Register_Indirect => Register_indirect_reg,
                IM => IM_Ry_reg,
                InterruptLine => interruptLine_S,
                ALUOp => ALUOp_reg,
                Sel => Sel_reg,
                wr => wr_addr_reg1,
                Rx => Rdx_reg,
                Ry => Rdy_reg,
                IM_data => IM_Data_reg,
                Zflg => zflg,
                clk => clk,
                InterruptLines => InterruptLines );
                
------------------Decoder To Execute Registers------------------

--Temp signals that are used to direct many outputs into as few registers as possible
TempSIn1(0) <= wr_e_reg1;
TempSIn1(1) <= ALU_DMem_Mux_reg1;
TempSIn1(5 downto 2) <= wr_addr_reg1;
TempSIn1(9 downto 6) <= ALUOp_reg;
TempSIn1(10) <= Register_indirect_reg;
TempSIn1(11) <= IM_Ry_reg;

--First stage register for signals that need to be delayed by two time units
D_REG_ES1: REG generic map ( W => 12 )
               port map (
                 CLK => clk,
                 D => TempSIn1,
                 Q => TempSOut1 );
                 
--Signals that only needed to be delayed one time unit
reg_ALUOp <= TempSOut1(9 downto 6);
reg_register_indirect <= TempSOut1(10);
reg_IM_Ry <= TempSOut1(11);
                 
--Second stage register for signals that need to be delayed by two time units
D_REG_ES2: REG generic map ( W => 10 )
               port map (
                 CLK => clk,
                 D => TempSOut1(9 downto 0),
                 Q => TempSOut2 );
                 
--Signals that have been delayed two time units
reg2_wr_e <= TempSOut2(0);
reg2_ALU_DMem_Mux <= TempSOut2(1);
reg2_wr_addr <= TempSOut2(5 downto 2);
reg2_ALUOp <= TempSOut2(9 downto 6);

--Encoding multi-bit outputs into a single signal
TempDEIn(3 downto 0) <= Sel_reg;
TempDEIn(7 downto 4) <= Rdx_reg;
TempDEIn(11 downto 8) <= Rdy_reg;
TempDEIn(19 downto 12) <= IM_Data_reg;

D_REG_E: REG generic map ( W => 20 )
             port map (
                 CLK => clk,
                 D => TempDEIn,
                 Q => TempDEOut );
                
--Decoding signal into multi-bit inputs to execute stage 
reg_Sel <= TempDEOut(3 downto 0);
reg_Rdx <= TempDEOut(7 downto 4);
reg_Rdy <= TempDEOut(11 downto 8);
reg_IM_Data <= TempDEOut(19 downto 12);

-------------------------Execute Port Map------------------------
  
E1: Execute port map (
                 wr_e => reg2_wr_e,
                 Register_Indirect => reg_register_indirect,
                 IM => reg_IM_Ry,
                 ALUOp => reg_ALUOp,
                 Sel => reg_Sel,
                 wr => reg2_wr_addr,
                 Rx => reg_Rdx,
                 Ry => reg_Rdy,
                 IM_data => reg_IM_Data,
                 WrBk => wrbk,
                 Interrupts => interrupts_en,
                 IrData => IrDataS,
                 RxD => RxDS,
                 RyD => RyDS,
                 ALUOut => aluout,
                 WriteData => WriteData_reg,
                 dAddr => dAddr_reg,
                 ALU_Answer => ALUAnswer_reg,
                 Zflg => zflg );
                 
-----------------Execute To WriteBack Registers-----------------

TempEWIn(7 downto 0) <= WriteData_reg;
TempEWIn(15 downto 8) <= dAddr_reg;
TempEWIn(23 downto 16) <= ALUAnswer_reg;

E_REG_W: REG generic map ( W => 24 )
             port map (
                 CLK => clk,
                 D => TempEWIn,
                 Q => TempEWOut );

reg_WriteData <= TempEWOut(7 downto 0);
reg_locationAddress <= TempEWOut(15 downto 8);
reg_ALUAnswer <= TempEWOut(23 downto 16);

------------------------WriteBack Port Map-----------------------
  
W1: WriteBack port map (
                 ALUOp => reg2_ALUOp,
                 writeData => reg_WriteData,
                 location_address => reg_locationAddress,
                 ALU_op_Mux_e => reg2_ALU_DMem_Mux,
                 ALU_Answer => reg_ALUAnswer,
                 wr_BK => wrbk );
                 
-------------------InterruptHandler Port Map---------------------  

IH1: InterruptHandler generic map ( S => 4, W => 8 )
                      port map (
                        Rdx => Rdx_reg,
                        Rdy => Rdy_reg,
                        Rxi => RxDS,
                        Ryi => RyDS,
                        PCi => currentPC,
                        InterruptLine => interruptLine_S,
                        En => interrupts_en,
                        Ro => IrDataS,
                        PCo => interrupt_a
                      );

end architecture;