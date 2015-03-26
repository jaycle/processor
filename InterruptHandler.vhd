LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY InterruptHandler IS
  GENERIC (
    S : integer;
    W : integer );
  PORT (
    Rdx, Rdy:       IN std_logic_vector(S-1 DOWNTO 0);
    Rxi, Ryi:       IN std_logic_vector(W-1 DOWNTO 0);
    PCi:            IN std_logic_vector(W-1 DOWNTO 0);
    InterruptLine:  IN std_logic_vector(1 DOWNTO 0);
    En:             IN std_logic;
    Ro:             OUT std_logic_vector(W-1 DOWNTO 0);
    PCo:            OUT std_logic_vector(W-1 DOWNTO 0) );
END ENTITY;

ARCHITECTURE Arch OF InterruptHandler IS
  
COMPONENT SCRATCHPAD IS
  GENERIC (
    S: integer;
    W: integer );
  PORT (
    Rdx, Rdy:       IN std_logic_vector(S-1 DOWNTO 0);
    Rxi, Ryi:       IN std_logic_vector(W-1 DOWNTO 0);
    PCi:            IN std_logic_vector(W-1 DOWNTO 0);
    InterruptLine:  IN std_logic_vector(1 DOWNTO 0);
    Wr:             IN std_logic;
    En:             IN std_logic;
    Ro:             OUT std_logic_vector(W-1 DOWNTO 0);
    PCo:            OUT std_logic_vector(W-1 DOWNTO 0) );
END COMPONENT;
FOR ALL: SCRATCHPAD USE ENTITY WORK.SCRATCHPAD(SCRATCHPAD_ARCH);

SIGNAL Wr_S: std_logic;
SIGNAL InterruptsState: std_logic := '1'; --'0' is beginning state where it saves all values, '1' is end state where it puts back all values

BEGIN
  
  SP: SCRATCHPAD 
  GENERIC MAP( 
    S => S, 
    W => W )
  PORT MAP( 
    Rdx => Rdx,
    Rdy => Rdy,
    Rxi => Rxi,
    Ryi => Ryi,
    PCi => PCi,
    InterruptLine => InterruptLine,
    Wr => Wr_S,
    En => En,
    Ro => Ro,
    PCo => PCo );
                 
  Enabling: PROCESS(En)
  BEGIN
    IF ( En'event AND En = '1' ) THEN
      IF ( InterruptsState = '0' ) THEN
        Wr_S <= '1';
      ELSIF ( InterruptsState = '1' ) THEN
        Wr_S <= '0';
      END IF;
    ELSIF( En'event AND En = '0' ) THEN
      InterruptsState <= NOT(InterruptsState);
      Wr_S <= '0';
    END IF;
  END PROCESS;

END ARCHITECTURE;