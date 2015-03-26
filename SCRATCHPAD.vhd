LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY SCRATCHPAD IS
  GENERIC (
    S : integer;
    W : integer );
  PORT (
    Rdx, Rdy:       IN std_logic_vector(S-1 DOWNTO 0);
    Rxi, Ryi:       IN std_logic_vector(W-1 DOWNTO 0);
    PCi:            IN std_logic_vector(W-1 DOWNTO 0);
    InterruptLine:  IN std_logic_vector(1 DOWNTO 0);
    Wr:             IN std_logic;
    En:             IN std_logic;
    Ro:             OUT std_logic_vector(W-1 DOWNTO 0);
    PCo:            OUT std_logic_vector(W-1 DOWNTO 0) );
END SCRATCHPAD;

ARCHITECTURE SCRATCHPAD_ARCH OF SCRATCHPAD IS
  TYPE DATA IS array((2**S) DOWNTO 0) OF std_logic_vector(W-1 DOWNTO 0);
  TYPE ADDR IS ARRAY(3 DOWNTO 0) OF std_logic_vector(W-1 DOWNTO 0);
  
  SIGNAL REG: DATA; --Internal signal that holds the data of the registers
  SIGNAL Internal: ADDR;
BEGIN
  
  Init: PROCESS
  BEGIN
    Internal(0) <= "11111000";
    Internal(1) <= "11111000";
    Internal(2) <= "11111000";
    Internal(3) <= "11111000";
    WAIT;
  END PROCESS;
  
  PROCESS(En, Rdx, Rdy, Wr, Rxi, Ryi, PCi)
  VARIABLE index: integer := 0; --Integer variable used to hold the address to read/write
  BEGIN
    IF ( En = '1' ) THEN
      IF( Wr = '0' ) THEN --If write is disabled and read is enabled
        index := conv_integer(Rdx); --Convert Rdx address into integer type
        Ro <= REG(index); --Data from the register at "index" is outputted via Ro
        
        if ( index < 2 ) then
          PCo <= REG((2**S)); --Data from the register at index 2**S is outputted via PCo.
        end if;
      ELSIF( Wr = '1' ) THEN --If write is enabled
        index := conv_integer(Rdx); --Convert Rdx address into integer type
        REG(index) <= Rxi; --Data at Rxi is written into the register at "index"
      
        index := conv_integer(Rdy); --Convert Rdy address into integer type
        REG(index) <= Ryi; --Data at Ryi is written into the register at "index"
      
        REG((2**S)) <= PCi; --Data at PCi is written into the register at index 2**S.
        
        PCo <= Internal(conv_integer(InterruptLine));
      END IF;
    ELSIF ( En = '0' ) THEN
      Ro <= (others => '0');
      PCo <= (others => '0');
    END IF;
  END PROCESS;
END ARCHITECTURE;