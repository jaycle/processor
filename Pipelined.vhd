library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.ALL;
Use Ieee.std_logic_unsigned.all;

entity Pipelined is
  port (
   	 clk: in std_logic
	);
end entity;

architecture Arch of Pipelined is

signal instr_to_reg, instr_to_dec : std_logic_vector(15 downto 0);
signal offsets,jump_address, imdata_to_reg, imdata_to_exec, dmem_to_reg, dmem_to_wr, alu_to_reg, alu_to_wr, wb_sig : std_logic_vector(7 downto 0);
signal RX_to_reg, RX_to_exec,RY_to_reg, RY_to_exec, wr_to_reg, wr_to_exec,OP_to_reg, OP_to_exec, Sel_to_reg, Sel_to_exec : std_logic_vector(3 downto 0);
signal branch_ens, jump_ens,Z_flags, ryim_to_reg, ryim_to_exec, dmemsel_to_reg, dmemsel_to_exec, wren_to_reg, wren_to_exec, wbsel_to_reg, wbsel_to_exec, wbsel_to_wr : std_logic; 

begin

fetch : entity work.fetch(Behav)
  Port Map(   
          offset => offsets,
          jump_A => jump_address,
          Clk => clk, 
          branch_en => branch_ens, 
	  jump_en => jump_ens,
	  instruction => instr_to_reg 
          );

fetch_decode : entity work.fetch_decode(arch)
  Port Map(   
          Clk => clk, 
          instr => instr_to_reg,
	  instruction => instr_to_dec 
          );

decoder : entity work.decode(Behav)
  Port Map(   
          clk => clk,
          z_flg => Z_flags,
	  instruction => instr_to_dec,
          rdx => RX_to_reg, 
	  rdy => RY_to_reg, 
	  wr => wr_to_reg,
	  alu_op => OP_to_reg,
	  alu_sel => Sel_to_reg,
          imdata => imdata_to_reg,  
	  offset => offsets,
	  jump_addr => jump_address,
	  ry_im => ryim_to_reg,
	  sel_dmem => dmemsel_to_reg,
	  wb_sel => wbsel_to_reg,
	  jump_en => jump_ens,
	  branch_en => branch_ens,
	  w_en => wren_to_reg 
          );


decode_execute : entity work.decode_execute(arch)
  Port Map(   
          clk => clk,
          rdx_in => RX_to_reg,
	  rdy_in => RY_to_reg, 
	  wr_in	=> wr_to_reg,
	  alu_op_in => OP_to_reg,
	  alu_sel_in =>  Sel_to_reg,
          imData_in => imdata_to_reg, 
       	  ry_im_in => ryim_to_reg,
	  sel_dmem_in => dmemsel_to_reg,
	  wb_sel_in  => wbsel_to_reg,
	  w_en_in => wren_to_reg, 
          rdx =>  RX_to_exec,
	  rdy => RY_to_exec,
	  wr => wr_to_exec,
	  alu_op => OP_to_exec,
	  alu_sel => Sel_to_exec,
          imData => imdata_to_exec, 
          ry_im => ryim_to_exec,
	  sel_dmem => dmemsel_to_exec,
	  wb_sel => wbsel_to_exec,
	  w_en => wren_to_exec
          );

execute : entity work.Execute(arch)
  Port Map( 
	  clk => clk,						
          ry_IM => ryim_to_exec,
	  w_en => wren_to_exec,
	  sel_dmem => dmemsel_to_exec,
          ALUop => OP_to_exec,
          Sel => Sel_to_exec,
          wraddr => wr_to_exec,
          Rx =>RX_to_exec,
          Ry => RY_to_exec, 
          IM_data => imdata_to_exec,
          WrBk => wb_sig,
          dmem_out => dmem_to_reg,  
          ALU_out => alu_to_reg,
          Zflg => Z_flags
          );

execute_writeback : entity work.Execute_writeback(arch)
  Port Map(
	  clk => clk,
   	  wb_sel => wbsel_to_exec,
  	  dmem_out => dmem_to_reg,
          ALU_out => alu_to_reg,
   	  wb_sel_out => wbsel_to_wr,
  	  dmem_out_out => dmem_to_wr,
          ALU_out_out => alu_to_wr
	);

Writeback : entity work.WriteBack(arch)
  Port Map(
	  wb_sel => wbsel_to_wr,
  	  dmem_out => dmem_to_wr,
          ALU_out => alu_to_wr, 
          wr_BK => wb_sig 
        );

end arch;
