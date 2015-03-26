LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.All; 
Use work.all;

entity Execute is
  
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
          
    
    end Execute;
    
Architecture arch of Execute is
  
component Register_Bank is
  GENERIC (
    S : integer;
    W : integer);
  PORT (
    Rdx, Rdy:   IN std_logic_vector(S-1 DOWNTO 0); --Address inputs
    WrBk:       IN std_logic_vector(W-1 DOWNTO 0); --Write back data
    WrAddr:     IN std_logic_vector(S-1 DOWNTO 0); --Address to write data into
    IrData:     IN std_logic_vector(W-1 DOWNTO 0); --Data from the Scratchpad
    Wr:         IN std_logic; --Write enable 
    Interrupts: IN std_logic; --Signal to alert register bank that interupts are active
    Rx, Ry:     OUT std_logic_vector(W-1 DOWNTO 0) ); --Data outputs
END component;

component Mux is 
  Port(   selectL : in std_logic;
          Min1 : in std_logic_vector(7 downto 0); --Select if SelectL is low
          Min2 : in std_logic_vector(7 downto 0); --Select if SelectL is High
          muxout : out std_logic_vector(7 downto 0)
          );
end component;

component ALU is
    port(
        Rx : in std_logic_vector( 7 downto 0);
        Ry: in std_logic_vector (7 downto 0);
        ALUop: in std_logic_vector (3 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        ALUout: out std_logic;
        ALU_Answer: out std_logic_vector(7 downto 0);
        zflg: out std_logic );
end component;
constant S: integer := 4;
constant W : integer := 8;

signal WrBk_s : std_logic_vector (W-1 downto 0);
Signal Ir_Data_S, Rx_R , Ry_R : std_logic_vector(W-1 downto 0); 
Signal Ry_Alu : std_logic_vector(7 downto 0);


for all: ALU use entity work.ALU_Final(arch);
for all: mux use entity work.mux_2_1(behavioral);
for all: Register_bank use entity work.Register_bank(Register_bank_arch);
 
 begin 
 
 RB : Register_Bank
 generic map (S=>S , W=>W) 
  port map (        
              Rdx=> Rx,
              Rdy=> Ry,
              WrBk=> WrBk,
              WrAddr=> wr,
              IrData=> IrData,
              Wr=> Wr_e,
              Interrupts=> Interrupts,
              Rx=> Rx_R,
              Ry=> Ry_R
          );
          
  process(Rx_R, Ry_R)
  begin
    RxD <= Rx_R;
    RyD <= Ry_R;
  end process;

MUX_RB_to_ALU : Mux 

  port map( 
            SelectL => IM, --Selector
            Min1=> Ry_R, --select if low
            Min2=> IM_Data, --select if high
            Muxout=> Ry_Alu
          );
          
Mux_Dec_to_ALU: Mux
  port map(
            SelectL => Register_Indirect, --Selector
            Min1=> IM_data, --select if low
            Min2=> Ry_R, --select if high
            Muxout=> dAddr
          );
ALU_P : ALU

  port map(
            Rx => Rx_R,
            Ry=> Ry_Alu,
            ALUop=> ALUop,
            Sel=> Sel,
            ALUout=> ALUout,
            ALU_Answer=> ALU_Answer,
            Zflg=> Zflg
        );
            
              
 process(Ry_R)
 begin 
   WriteData<=Rx_R;
 end process;

end arch; 