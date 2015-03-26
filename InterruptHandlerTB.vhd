LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY InterruptHandlerTB IS
END ENTITY;

ARCHITECTURE Arch OF InterruptHandlerTB IS
  
COMPONENT InterruptHandler IS
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
END COMPONENT;
FOR ALL: InterruptHandler USE ENTITY WORK.InterruptHandler(Arch);

SIGNAL EnS: std_logic;
SIGNAL InterruptLineS: std_logic_vector(1 DOWNTO 0);
SIGNAL RdxS, RdyS: std_logic_vector(3 DOWNTO 0);
SIGNAL RxiS, RyiS, PCiS, RoS, PCoS: std_logic_vector(7 DOWNTO 0);

CONSTANT period: time := 1 ns;

BEGIN
  
  IH: InterruptHandler 
  GENERIC MAP(
    S => 4,
    W => 8 )
  PORT MAP(
    Rdx => RdxS,
    Rdy => RdyS,
    Rxi => RxiS,
    Ryi => RyiS,
    PCi => PCiS,
    InterruptLine => InterruptLineS,
    En => EnS,
    Ro => RoS,
    PCo => PCoS );
    
  Test: PROCESS
  BEGIN
    EnS <= '0';
    RdxS <= "0000";
    RdyS <= "0000";
    RxiS <= "00000000";
    RyiS <= "00000000";
    PCiS <= "00000000";
    InterruptLineS <= "00";
    wait for period;
    
    EnS <= '1';
    RdxS <= "0000";
    RdyS <= "0001";
    RxiS <= "00000111";
    RyiS <= "00100010";
    PCiS <= "00000110";
    InterruptLineS <= "00";
    wait for period;
    
    RdxS <= "0010";
    RdyS <= "0011";
    RxiS <= "10010110";
    RyiS <= "00110100";
    PCiS <= "00000110";
    InterruptLineS <= "01";
    wait for period;
    
    RdxS <= "0100";
    RdyS <= "0101";
    RxiS <= "00000110";
    RyiS <= "01010100";
    PCiS <= "01100010";
    InterruptLineS <= "00";
    wait for period;
    
    EnS <= '0';
    wait for period;
    
    EnS <= '1';
    RdxS <= "0000";
    wait for period;
    
    EnS <= '1';
    RdxS <= "0001";
    wait for period;
    
    EnS <= '1';
    RdxS <= "0010";
    wait for period;
    
    EnS <= '1';
    RdxS <= "0011";
    wait for period;
    
    EnS <= '1';
    RdxS <= "0100";
    wait for period;
    
    EnS <= '1';
    RdxS <= "0101";
    wait for period;
    
  END PROCESS;

END ARCHITECTURE;