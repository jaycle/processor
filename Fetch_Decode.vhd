LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Fetch_Decode IS
  PORT (
    Clk: IN std_logic;
    instr : IN std_logic_vector (15 downto 0);
    instruction : OUT std_logic_vector (15 downto 0) 
	);
END Fetch_Decode;

ARCHITECTURE arch OF Fetch_Decode IS
BEGIN
  PROCESS(Clk)
  BEGIN
    IF rising_edge(clk) THEN
	  instruction <= instr; 
    END IF;
  END PROCESS;
END ARCHITECTURE;
