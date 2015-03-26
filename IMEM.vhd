LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.math_real.ALL;

ENTITY IMEM IS
  GENERIC (
    S: integer := 8;
    W: integer := 16);
  PORT (
    Addr:  IN std_logic_vector(S-1 DOWNTO 0);
    Instr: OUT std_logic_vector(W-1 DOWNTO 0) );
END ENTITY;

ARCHITECTURE IMEM_ARCH OF IMEM IS

TYPE DATA IS ARRAY((2**S)-1 DOWNTO 0) OF std_logic_vector(W-1 DOWNTO 0);
SIGNAL MEM: DATA;
  
BEGIN
  
  Init: PROCESS --INITIALIZATION PROCESS FOR THE PURPOSE OF POPULATING IMEM AND REGISTER BANK
  VARIABLE seed1, seed2:  positive;
  VARIABLE rand:          real;
  VARIABLE int_rand:      integer;
  VARIABLE Rx, Ry:        std_logic_vector(3 DOWNTO 0);
  VARIABLE Data:          std_logic_vector(7 DOWNTO 0);
  VARIABLE Temp:          std_logic_vector(W-1 DOWNTO 0);
  BEGIN
    FOR i IN 0 TO ((2**S)-1) LOOP
      
      UNIFORM(seed1, seed2, rand); --FUNCTION USED TO FIND RANDOM VALUE, SAVED IN rand
      int_rand := INTEGER(TRUNC(real(rand*1000.0))); --CONVERT REAL TO INTEGER
      Rx := std_logic_vector(to_unsigned(int_rand, Rx'LENGTH)); --CONVERT INTEGER TO STD_LOGIC_VECTOR AND SAVE IN Rx
      
      UNIFORM(seed1, seed2, rand);
      int_rand := INTEGER(TRUNC(real(rand*1000.0)));
      Ry := std_logic_vector(to_unsigned(int_rand, Ry'LENGTH));
      
      IF ( i < 32 ) THEN      --ADD IMMEDIATE FOR THE PURPOSE OF INITIALIZING REGISTER BANK
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
        Rx := std_logic_vector(to_unsigned(i,Rx'Length));
        MEM(i)(15 DOWNTO 12) <= "0001";
        MEM(i)(11 DOWNTO 8) <= Rx;
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 40 ) THEN  --NO OPERATION
        MEM(i) <= "0000000000000000";
      ELSIF ( i < 48 ) THEN  --ADD IMMEDIATE
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
      
        MEM(i)(15 DOWNTO 12) <= "0001";
        MEM(i)(11 DOWNTO 8) <= Rx;
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 56 ) THEN  --ADD 
        MEM(i)(15 DOWNTO 8) <= "00100000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 64 ) THEN  --SUBTRACT
        MEM(i)(15 DOWNTO 8) <= "00100001";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 72 ) THEN  --INCREMENT
        MEM(i)(15 DOWNTO 8) <= "00110000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 80 ) THEN  --DECREMENT
        MEM(i)(15 DOWNTO 8) <= "00110001";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 88 ) THEN  --SHIFT LEFT
        MEM(i)(15 DOWNTO 8) <= "01000000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 96 ) THEN  --SHIFT RIGHT
        MEM(i)(15 DOWNTO 8) <= "01000001";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 104 ) THEN --LOGICAL NOT
        MEM(i)(15 DOWNTO 8) <= "01010000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 112 ) THEN --LOGICAL NOR
        MEM(i)(15 DOWNTO 8) <= "01010001";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 120 ) THEN --LOGICAL NAND
        MEM(i)(15 DOWNTO 8) <= "01010010";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 128 ) THEN --LOGICAL XOR
        MEM(i)(15 DOWNTO 8) <= "01010011";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 136 ) THEN --LOGICAL AND 
        MEM(i)(15 DOWNTO 8) <= "01010100";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 144 ) THEN --LOGICAL OR 
        MEM(i)(15 DOWNTO 8) <= "01010101";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 152 ) THEN --CLEAR
        MEM(i)(15 DOWNTO 8) <= "01010110";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 160 ) THEN --SET 
        MEM(i)(15 DOWNTO 8) <= "01010111";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 168 ) THEN --SET IF LESS THAN
        MEM(i)(15 DOWNTO 8) <= "01011111";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 176 ) THEN --MOVE
        MEM(i)(15 DOWNTO 8) <= "01011000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 184 ) THEN --ENABLE INTERRUPTS
        MEM(i)(15 DOWNTO 8) <= "01110000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 192 ) THEN --LOAD INDIRECT
        MEM(i)(15 DOWNTO 8) <= "10000000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 200 ) THEN --STORE INDIRECT
        MEM(i)(15 DOWNTO 8) <= "10010000";
        MEM(i)(7 DOWNTO 4) <= Rx;
        MEM(i)(3 DOWNTO 0) <= Ry;
      ELSIF ( i < 208 ) THEN --LOAD REGISTER
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
        
        MEM(i)(15 DOWNTO 12) <= "1010";
        MEM(i)(11 DOWNTO 8) <= Rx;
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 216 ) THEN --STORE REGISTER
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
        
        MEM(i)(15 DOWNTO 12) <= "1011";
        MEM(i)(11 DOWNTO 8) <= Rx;
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 224 ) THEN --JUMP
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
        
        MEM(i)(15 DOWNTO 8) <= "11000000";
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 232 ) THEN --BRANCH IF ZERO
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
        
        MEM(i)(15 DOWNTO 12) <= "1101";
        MEM(i)(11 DOWNTO 8) <= Rx;
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 240 ) THEN --BRANCH IF NOT ZERO
        UNIFORM(seed1, seed2, rand);
        int_rand := INTEGER(TRUNC(real(rand*1000.0)));
        Data := std_logic_vector(to_unsigned(int_rand, Data'LENGTH));
        
        MEM(i)(15 DOWNTO 12) <= "1110";
        MEM(i)(11 DOWNTO 8) <= Rx;
        MEM(i)(7 DOWNTO 0) <= Data;
      ELSIF ( i < 248 ) THEN --RETURN FROM INTERRUPT
        MEM(i) <= "1111000000000000";
      ELSE                   --FILL REST OF INSTRUCTIONS TO NOP
        MEM(248) <= "0001001000110011";
        MEM(249) <= "0010000100110100";
        MEM(250) <= "1011001000001111";
        MEM(251) <= "1111000000000000";
      END IF;
    END LOOP;
    
    MEM(0) <= "0111000000000000";
    MEM(1) <= "1101000000000110";
    
    WAIT;
  END PROCESS Init;
  
  Output: PROCESS(Addr)
  BEGIN
    Instr <= MEM(conv_integer(Addr));
  END PROCESS Output;
  
END ARCHITECTURE;