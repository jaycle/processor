LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY REGISTER_BANK IS
  GENERIC (
    S : integer := 4;
    W : integer := 8);
  PORT (
    clk	:		in std_logic; 
    Rdx, Rdy:   IN std_logic_vector(S-1 DOWNTO 0); --Address inputs
    WrBk:       IN std_logic_vector(W-1 DOWNTO 0); --Write back data
    WrAddr:     IN std_logic_vector(S-1 DOWNTO 0); --Address to write data into
   -- IrData:     IN std_logic_vector(W-1 DOWNTO 0); --Data from the Scratchpad
    Wr:         IN std_logic; --Write enable 
    --Interrupts: IN std_logic; --Signal to alert register bank that interupts are active
    Rx, Ry:     OUT std_logic_vector(W-1 DOWNTO 0) ); --Data outputs
END REGISTER_BANK;

ARCHITECTURE REGISTER_BANK_ARCH OF REGISTER_BANK IS
  TYPE DATA IS array(0 to (2**S-1)) OF std_logic_vector(W-1 DOWNTO 0);
  
  SIGNAL REG: DATA := (others => (others => '0')); --Internal signal that holds the data of the registers
BEGIN
  
  PROCESS(clk, Rdx, Rdy)
  BEGIN
   -- IF( Interrupts = '0' ) THEN --If Interrupts is low then the registers function as normal.

--  Default values 
  Rx <= REG(to_integer(unsigned(Rdx)));       
  Ry <= REG(to_integer(unsigned(Rdy))); 

	if (falling_edge(clk)) then
	-- write only on falling edge
     	  IF( Wr = '1' ) THEN
     	       REG(to_integer(unsigned(WrAddr))) <= WrBk; --Write back data is written into the register at "index"
	  end if; -- wr

	end if; -- clk


--    ELSIF( Interrupts = '1' ) THEN --If Ir is high then the registers are either being written into the scratchpad or 
                           --the registers are receiving values from the scratchpad.
--      index := conv_integer(Rdx);
--      Rx <= REG(index);
        
--      index := conv_integer(Rdy);
--      Ry <= REG(index);
      
--      IF( Wr = '1' ) THEN --If write is enabled
 --       index := conv_integer(WrAddr); --Convert Rdx address into integer type
--        REG(index) <= IrData; --Write back data is written into the register at "index"
--      END IF;
 --   END IF;
  END PROCESS;
END ARCHITECTURE;