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
	MEM(3) <= ADDI  & "0010" & "10001000";
	MEM(4) <= NOP;
	MEM(5) <= NOP;
	MEM(8) <= NOP;
	MEM(9) <= ADD  	& "0011" & "0000";
	MEM(10) <= SUB 	& "0010" & "0001";
	MEM(11) <= INC 	& "0000" & "0000"; -- Ry not used
	MEM(12) <= DEC 	& "0011" & "0000"; -- Ry not used
	MEM(13) <= SET 	& "0100" & "0000";
	MEM(14) <= SHL 	& "0001" & "0001"; 
	MEM(15) <= SHR 	& "0010" & "0001";
	MEM(16) <= LNOT	& "0011" & "0000";
	MEM(17) <=LNOR 	& "0100" & "0000";
	MEM(18) <=LNAND	& "0000" & "0000";
	MEM(19) <=LXOR 	& "0001" & "0000";
	MEM(20) <=LAND 	& "0010" & "0000";
	MEM(21) <=LOR  	& "0011" & "0000";
	MEM(22) <=CLR  	& "0100" & "0000";  -- clear reg for slt instr
	MEM(23) <=SET  	& "0101" & "0000";  -- set reg for slt instr
	MEM(24) <=SLT 	& "0100" & "0101";  -- Rx should go from zero to 1
	MEM(25) <=MOV  	& "0100" & "1111";  -- Last Rx to reg15
	MEM(26) <=EI	& "0000" & "1111";  -- enables all 4 interupts
	MEM(27) <= STIN & "1111" & "0000";  -- store Value at Ry into MEM[1]
	MEM(28) <= LDIN & "1110" & "1111";  -- load back Value into R14
	MEM(29) <= STR	& "0000" & "00000010" ; -- store in MEM[2]
	MEM(30) <= LDR	& "0001" & "00000010" ; -- load from MEM[2]
	MEM(31) <= JMP  		 & "00011011" ; -- JUMP to IMEM[27]
	MEM(32) <= NOP;  -- should be skipped
	MEM(33) <= NOP;  -- ditto  
	MEM(34) <= NOP;  -- gets executed
	MEM(35) <= CLR  & "0000" & "0000";


   -- ask about JZ and JNZ commands  
  Output: process(addr)
  begin
    Instr <= MEM(conv_integer(Addr));
  end process Output;  
END ARCHITECTURE;
