LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Decode_Execute IS
  PORT (
   	clk: in std_logic;
	rdx_in,rdy_in,wr_in,alu_op_in,alu_sel_in : in std_logic_vector (3 downto 0);
        imData_in: in std_logic_vector (7 downto 0);
        ry_im_in, sel_dmem_in, wb_sel_in, w_en_in : in std_logic;
        rdx,rdy,wr,alu_op,alu_sel : out std_logic_vector (3 downto 0);
        imData : out std_logic_vector (7 downto 0);
        ry_im, sel_dmem, wb_sel, w_en : out std_logic
	);
END Decode_Execute;

ARCHITECTURE arch OF Decode_Execute IS
BEGIN
  PROCESS(Clk)
  BEGIN
    IF rising_edge(clk) THEN
	  rdx <= rdx_in; 
	  rdy <= rdy_in; 
	  wr <= wr_in; 
	  alu_op <= alu_op_in; 
	  alu_sel <= alu_sel_in; 
	  imdata <= imdata_in; 
	  ry_im <= ry_im_in; 
	  sel_dmem <= sel_dmem_in; 
	  wb_sel <= wb_sel_in; 
	  w_en <= w_en_in; 
    END IF;
  END PROCESS;
END ARCHITECTURE;
