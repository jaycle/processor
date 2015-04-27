LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Fetch_Decode IS
  PORT (
    clr: in std_logic;
    Clk: IN std_logic;
    instr : IN std_logic_vector (15 downto 0);
    instruction : OUT std_logic_vector (15 downto 0) 
	);
END Fetch_Decode;

ARCHITECTURE arch OF Fetch_Decode IS
BEGIN

  PROCESS(Clk, clr)
  BEGIN
	if clr = '1' then
		instruction <= "0000000000000000";
        elsIF rising_edge(clk) THEN
	  	instruction <= instr;
	end if;
  END PROCESS;
END ARCHITECTURE;
