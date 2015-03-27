LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY IMEM IS
  GENERIC (
  	add_w: integer := 8
    depth: integer := 2**8;
    width: integer := 16);
  PORT (
    Addr:  IN std_logic_vector(add_w-1 DOWNTO 0);
    Instr: OUT std_logic_vector(width-1 DOWNTO 0) );
END ENTITY;

ARCHITECTURE IMEM_ARCH OF IMEM IS

TYPE DATA IS ARRAY((depth)-1 DOWNTO 0) OF std_logic_vector(width-1 DOWNTO 0);
SIGNAL MEM: DATA;
  
BEGIN
	-- Fill array manually with instructions to be executed 
  
END ARCHITECTURE;
