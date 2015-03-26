LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY REG IS
  GENERIC (
    W : integer );
  PORT (
    D:   IN std_logic_vector(W-1 DOWNTO 0);
    Clk: IN std_logic;
    Q:   OUT std_logic_vector(W-1 DOWNTO 0) );
END REG;

ARCHITECTURE REGISTER_ARCH OF REG IS
BEGIN
  PROCESS(Clk)
  BEGIN
    IF ( Clk'event and Clk = '1' ) THEN
      Q <= D;
    END IF;
  END PROCESS;
END ARCHITECTURE;