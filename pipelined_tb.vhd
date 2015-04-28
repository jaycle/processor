library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
-- empty
end entity;

architecture arch of tb is

constant period : time := 100 ns;
constant num_cycles : integer := 100;
signal clk : std_logic;

begin
	uut : entity work.pipelined(arch)
		port map (clk => clk);

	stim : process is
	begin
	for i in 0 to num_cycles loop
		clk <= '1';
		wait for (period/2);
		clk <= '0';
		wait for (period/2);
	end loop;
	wait; -- forever
	end process;
	
end architecture;
	