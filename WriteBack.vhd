LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.All; 
Use work.all;

entity WriteBack is
  
  port (
	  wb_sel : in std_logic;
  	  dmem_out : in std_logic_vector(7 downto 0);
          ALU_out : in std_logic_vector(7 downto 0);
          wr_BK : out std_logic_vector(7 downto 0)
        );
end WriteBack;

architecture arch of WriteBack is
begin 
  
      
mux : entity work.mux_2_1(behav)
  Port Map(   
          selectL => wb_sel, 
          Min1 => ALU_out, --select if low
          Min2 => dmem_out, --select if high
          muxout => wr_Bk
          );

end arch;