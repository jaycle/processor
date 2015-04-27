LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.All; 
Use work.all;

entity Execute is
  
  port ( 
	  clk : in std_logic;
          ry_IM: in std_logic;
	  w_en : in std_logic;
	  sel_dmem : in std_logic;
          ALUop : in std_logic_vector(3 downto 0);
          Sel : in std_logic_vector (3 downto 0);
          wraddr : in std_logic_vector(3 downto 0); 
          Rx : in std_logic_vector (3 downto 0);
          Ry : in std_logic_vector(3 downto 0);
          IM_data : in std_logic_vector(7 downto 0);
          WrBk : in std_logic_vector(7 downto 0);  
          dmem_out : out std_logic_vector(7 downto 0); 
          ALU_out : out std_logic_vector(7 downto 0);
          Zflg : out std_logic
          );
    end Execute;
    
Architecture arch of Execute is
  
component Register_Bank is
  GENERIC (
    S : integer;
    W : integer);
  PORT (
    clk:        in std_logic;
    Rdx, Rdy:   IN std_logic_vector(S-1 DOWNTO 0); --Address inputs
    WrBk:       IN std_logic_vector(W-1 DOWNTO 0); --Write back data
    WrAddr:     IN std_logic_vector(S-1 DOWNTO 0); --Address to write data into
    Wr:         IN std_logic; --Write enable 
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
        Rx_in : in std_logic_vector( 7 downto 0);
        Ry_in: in std_logic_vector (7 downto 0);
        op: in std_logic_vector (3 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        ALU_out: out std_logic_vector(7 downto 0);
        z_flag: out std_logic );
end component;

component DMEM is
  generic(N:integer := 8); 
  port(
	   clk : in std_logic;
       ALUop :in std_logic_vector(3 downto 0);
       writeData :in std_logic_vector(N-1 downto 0);
       location_address : in std_logic_vector(N-1 downto 0);
       data_out :out std_logic_vector(N-1 downto 0));   
end component;

constant S: integer := 4;
constant W : integer := 8;

--signal WrBk_s : std_logic_vector (W-1 downto 0);
Signal Rx_R , Ry_R : std_logic_vector(W-1 downto 0); 
Signal Ry_Alu,dAddr : std_logic_vector(7 downto 0);


for all: ALU use entity work.ALU_Final(behav);
for all: mux use entity work.mux_2_1(behavioral);
for all: dmem use entity work.DMEM(arch);
for all: Register_bank use entity work.Register_bank(Register_bank_arch);
 
 begin 
 
 RB : Register_Bank
 generic map (S=>S , W=>W) 
  port map (        
              clk => clk,      
	      Rdx=> Rx,
              Rdy=> Ry,
              WrBk=> WrBk,
              WrAddr=> wrAddr,
              Wr=> W_en,
              Rx=> Rx_R,
              Ry=> Ry_R
          );       

MUX_RB_to_ALU : Mux 

  port map( 
            SelectL => ry_IM, --Selector
            Min1=> Ry_R, --select if low
            Min2=> IM_Data, --select if high
            Muxout=> Ry_Alu
          );
          
Mux_Dec_to_dmem: Mux
  port map(
            SelectL => sel_dmem, --Selector
            Min1=> IM_data, --select if low
            Min2=> Rx_R, --select if high
            Muxout=> dAddr
          );
ALU_P : ALU

  port map(
            Rx_in => Rx_R,
            Ry_in=> Ry_Alu,
            op=> ALUop,
            Sel=> Sel,
            ALU_out=> ALU_out,
            Z_flag=> Zflg
        );
            
memory : dmem
  port map(
	   clk => clk,
       ALUop => ALUop,
       writeData => Ry_R,
       location_address => dAddr,
       data_out =>  dmem_out
	);
end arch; 