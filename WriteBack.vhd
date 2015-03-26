LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.All; 
Use work.all;

entity WriteBack is
  
  port (
          ALUop: in std_logic_vector(3 downto 0);
          writeData :in std_logic_vector(7 downto 0);
          location_address : in std_logic_vector(7 downto 0);
          ALU_op_mux_e : in std_logic;
          ALU_Answer : in std_logic_vector(7 downto 0);
          wr_BK : out std_logic_vector(7 downto 0)
        );
end WriteBack;

architecture arch of WriteBack is
  
  component Mux 
  Port(   selectL : in std_logic;
          Min1 : in std_logic_vector(7 downto 0); --Select if SelectL is low
          Min2 : in std_logic_vector(7 downto 0); --Select if SelectL is High
          muxout : out std_logic_vector(7 downto 0)
          );
 end component;
 
 component DMEM is
    generic(N:integer); 
    port(
       ALUop :in std_logic_vector(3 downto 0);
       Writedata :in std_logic_vector(N-1 downto 0);
       location_address : in std_logic_vector(N-1 downto 0);
       data_out :out std_logic_vector(N-1 downto 0));
    end component;
  constant N: integer:=8;

signal memD : std_logic_vector(N-1 downto 0);
for all: DMEM use entity work.DMEM(arch);
for all: mux use entity work.mux_2_1(behavioral);

begin 
  
portmap : DMEM
  generic map (N=>N)
  port map (
           ALUop =>ALUop,
           Writedata =>writeData,
           location_address =>location_Address,
           data_out => memD);
       
portMUX : Mux
  Port Map(   
          selectL => ALU_op_mux_e, 
          Min1 => ALU_Answer, --select if low
          Min2 => memD, --select if high
          muxout => wr_Bk
          );
          
end arch;