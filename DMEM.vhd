Library ieee;
Use ieee.std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity DMEM is
  generic(N:integer := 8); 
  port(
	   clk : in std_logic;
       ALUop :in std_logic_vector(3 downto 0);
       writeData :in std_logic_vector(N-1 downto 0);
       location_address : in std_logic_vector(N-1 downto 0);
       data_out :out std_logic_vector(N-1 downto 0)); 
       
end DMEM;

architecture arch of DMEM is

type memory is array (0 to (2**N)-1) of std_logic_vector(N-1 downto 0);
   signal mem: memory := (others => (others => '0'));

BEGIN
  
process(clk, ALUop, writeData,Location_address) is

  begin
	if (falling_edge(clk)) then
      if ALUop = "1001" or ALUop ="1011" then  --Store on 0x9 or 0xB
        mem(to_integer(unsigned(location_address))) <= WriteData;
	  end if;

    elsif(ALUop="1000" or ALUop = "1010") then --Load on 0x8 or 0xA
       data_out <= mem(to_integer(unsigned(location_address))); 
	else
		data_out <= (others => '0');   
    end if;

  end process;

end architecture arch;