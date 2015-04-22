LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY IMEM IS
  GENERIC (
  	add_w: integer := 8;
    depth: integer := 2**8;
    width: integer := 16);
  PORT (
    Addr:  IN std_logic_vector(add_w-1 DOWNTO 0);
    Instr: OUT std_logic_vector(width-1 DOWNTO 0) );
END ENTITY;

ARCHITECTURE IMEM_ARCH OF IMEM IS
constant NOP : std_logic_vector(15 downto 0) := "0000000000000000"; 
constant ADDI : std_logic_vector(3 downto 0) := "0001";
constant ADD : std_logic_vector(7 downto 0) := "00100000"; 
constant SUB : std_logic_vector(7 downto 0) := "00100001"; 
constant INC : std_logic_vector(7 downto 0) := "00110000"; 
constant DEC : std_logic_vector(7 downto 0) :=  "00110001"; 
constant SHL : std_logic_vector(7 downto 0) := "01000000"; 
constant SHR : std_logic_vector(7 downto 0) := "01000001"; 
constant LNOT : std_logic_vector(7 downto 0) := "01010000"; 
constant LNOR : std_logic_vector(7 downto 0) := "01010001"; 
constant LNAND : std_logic_vector(7 downto 0) := "01010010"; 
constant LXOR : std_logic_vector(7 downto 0) := "01010011"; 
constant LAND : std_logic_vector(7 downto 0) := "01010100"; 
constant LOR : std_logic_vector(7 downto 0) := "01010101"; 
constant CLR : std_logic_vector(7 downto 0) := "01010110"; 
constant SET : std_logic_vector(7 downto 0) := "01010111"; 
constant SLT : std_logic_vector(7 downto 0) := "01011111"; 
constant MOV : std_logic_vector(7 downto 0) := "01011000"; 
constant EI : std_logic_vector(7 downto 0) := "01110000"; 
constant LDIN : std_logic_vector(7 downto 0) := "10000000"; 
constant STIN : std_logic_vector(7 downto 0) := "10010000"; 
constant LDR : std_logic_vector(3 downto 0) := "1010"; 
constant STR : std_logic_vector(3 downto 0) := "1011"; 
constant JMP : std_logic_vector(7 downto 0) := "11000000"; 
constant JZ : std_logic_vector(7 downto 0) := "11010000"; 
constant JNZ : std_logic_vector(7 downto 0) := "11100000"; 
constant RETI : std_logic_vector(7 downto 0) := "11110000"; 

TYPE data IS ARRAY(0 to (depth-1)) OF std_logic_vector(width-1 DOWNTO 0);
SIGNAL mem: data;
  
BEGIN
    -- Manually filled instructions
--            INST - Rx    - Ry/Im
	MEM(0) <= NOP;  -- first instruction
	MEM(1) <= ADDI 	& "0000" & "00001111";
	MEM(2) <= ADDI 	& "0001" & "00110011";
	MEM(3) <= ADD  	& "0010" & "0001";
	MEM(4) <= SUB  	& "0011" & "0010";
	MEM(5) <= INC  	& "0011"	& "0000"; -- Ry not used
	MEM(6) <= DEC  	& "0011" & "0000"; -- Ry not used
	MEM(7) <= SET  	& "0100" & "0000";
	MEM(8) <= SHL  	& "0100" & "0001"; 
	MEM(9) <= SHR  	& "0100" & "0001";
	MEM(10) <= LNOT 	& "0000" & "0000";
	MEM(11) <=LNOR 	& "0001" & "0000";
	MEM(12) <=LNAND	& "0001" & "0000";
	MEM(13) <=LXOR 	& "0001" & "0000";
	MEM(14) <=LAND 	& "0001" & "0000";
	MEM(15) <=LOR  	& "0001" & "0000";
	MEM(16) <=CLR  	& "0100" & "0000";  -- clear reg for slt instr
	MEM(17) <=SET  	& "0101" & "0000";  -- set reg for slt instr
	MEM(18) <=SLT 	& "0100" & "0101";  -- Rx should go from zero to 1
	MEM(19) <=MOV  	& "0100" & "1111";  -- Last Rx to reg15
	MEM(20) <=EI	& "0000" & "1111";  -- enables all 4 interupts
	MEM(21) <= STIN & "1111" & "0000";  -- store Value at Ry into MEM[1]
	MEM(22) <= LDIN & "1110" & "1111";  -- load back Value into R14
	MEM(23) <= STR	& "0000" & "00000010" ; -- store in MEM[2]
	MEM(24) <= LDR	& "0001" & "00000010" ; -- load from MEM[2]
	MEM(25) <= JMP  		 & "00011011" ; -- JUMP to IMEM[27]
	MEM(26) <= NOP;  -- should be skipped
	MEM(27) <= NOP;  -- ditto  
	MEM(28) <= NOP;  -- gets executed
	MEM(29) <= CLR  & "0000" & "0000";
   -- ask about JZ and JNZ commands  
  Output: process(addr)
  begin
    Instr <= MEM(conv_integer(Addr));
  end process Output;  
END ARCHITECTURE;
