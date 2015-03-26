library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.ALL;
use Ieee.std_logic_unsigned.all;

entity FinalPipelineTB is
end entity;

architecture Arch of FinalPipelineTB is
  
component FinalPipeline is
  port (
    clk: in std_logic;
    InterruptLines: in std_logic_vector(3 downto 0) );
end component;
FOR ALL: FinalPipeline use entity work.FinalPipeline(Arch);

signal clk_s: std_logic;
signal InterruptLines_s: std_logic_vector(3 downto 0);
constant clock_period: time := 1 ns; 

begin
  
  FP: FinalPipeline port map(
    clk => clk_s,
    InterruptLines => InterruptLines_s );
  
  InterruptLines_s <= "0000";
  
  process
  begin
    clk_s <= '0';
    wait for clock_period/2;
    clk_s <= '1';
    wait for clock_period/2;
  end process;
  
end architecture;