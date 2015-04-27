LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Execute_WriteBack IS
  PORT (
	  clr : in std_logic;
	  clk : in std_logic;
   	  wb_sel : in std_logic;
  	  dmem_out : in std_logic_vector(7 downto 0);
          ALU_out : in std_logic_vector(7 downto 0);
   	  wb_sel_out : out std_logic;
  	  dmem_out_out : out std_logic_vector(7 downto 0);
          ALU_out_out : out std_logic_vector(7 downto 0)
	);
END Execute_WriteBack;

ARCHITECTURE arch OF Execute_WriteBack IS
BEGIN

  PROCESS(Clk)
  BEGIn
    if clr = '1' then
	  wb_sel_out <= '0'; 
	  dmem_out_out <= (others => '0'); 
	  ALU_out_out <= (others => '0'); 
    elsIF rising_edge(clk) THEN
	  wb_sel_out <= wb_sel; 
	  dmem_out_out <= dmem_out; 
	  ALU_out_out <= ALU_out; 
    END IF;
  END PROCESS;
END ARCHITECTURE;
