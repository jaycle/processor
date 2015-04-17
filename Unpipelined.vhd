library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.ALL;
Use Ieee.std_logic_unsigned.all;

entity Unpipelined is
  port (
   	 clk: in std_logic
	);
end entity;

architecture Arch of Unpipelined is

signal instr : std_logic_vector(15 downto 0);
signal offsets,jump_address, imdata_sig, dmem_sig, alu_sig, wb_sig : std_logic_vector(7 downto 0);
signal RX_addr,RY_addr, wr_sig,OP_sig, Sel_sig : std_logic_vector(3 downto 0);
signal branch_ens, jump_ens,Z_flags, ryim_sig, dememsel_sig, wren_sig, wbsel_sig : std_logic; 

begin

fetch : entity work.fetch(Behav)
  Port Map(   
          offset => offsets,
          jump_A => jump_address,
          Clk => clk, 
          branch_en => branch_ens, 
	  jump_en => jump_ens,
	  instruction => instr 
          );


decoder : entity work.decode(Behav)
  Port Map(   
          clk => clk,
          z_flg => Z_flags,
	  instruction => instr,
          rdx => RX_addr, 
	  rdy => RY_addr, 
	  wr => wr_sig,
	  alu_op => OP_sig,
	  alu_sel => Sel_sig,
          imdata => imdata_sig,  
	  offset => offsets,
	  jump_addr => jump_address,
	  ry_im => ryim_sig,
	  sel_dmem => dememsel_sig,
	  wb_sel => wbsel_sig,
	  jump_en => jump_ens,
	  branch_en => branch_ens,
	  w_en => wren_sig 
          );

execute : entity work.Execute(arch)
  Port Map( 
	  clk => clk,
          ry_IM => ryim_sig,
	  w_en => wren_sig,
	  sel_dmem => dememsel_sig,
          ALUop => OP_sig,
          Sel => Sel_sig,
          wraddr => wr_sig,
          Rx => RX_addr,
          Ry => RY_addr, 
          IM_data => imdata_sig,
          WrBk => wb_sig,
          dmem_out => dmem_sig,  
          ALU_out => alu_sig,
          Zflg => Z_flags
          );
Writeback : entity work.WriteBack(arch)
  Port Map(
	  wb_sel => wbsel_sig,
  	  dmem_out => dmem_sig, 
          ALU_out => alu_sig, 
          wr_BK => wb_sig 
        );

end arch;
