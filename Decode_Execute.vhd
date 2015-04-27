LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Decode_Execute IS
  PORT (
	clr : in std_logic;
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
signal w_en_inter : std_logic;
signal wr_inter : std_logic_vector(3 downto 0);

BEGIN

  single : PROCESS(Clk)
  BEGIN
    	if clr = '1' then
 	  rdx <= (others => '0'); 
	  rdy <= (others => '0'); 
	  wr_inter <= (others => '0'); 
	  alu_op <= (others => '0'); 
	  alu_sel <= (others => '0'); 
	  imdata <= (others => '0'); 
	  ry_im <= '0'; 
	  sel_dmem <= '0'; 
	  wb_sel <= '0'; 
	  w_en_inter <= '0'; 
        elsIF rising_edge(clk) THEN
	  rdx <= rdx_in; 
	  rdy <= rdy_in; 
	  wr_inter <= wr_in; 
	  alu_op <= alu_op_in; 
	  alu_sel <= alu_sel_in; 
	  imdata <= imdata_in; 
	  ry_im <= ry_im_in; 
	  sel_dmem <= sel_dmem_in; 
	  wb_sel <= wb_sel_in; 
	  w_en_inter <= w_en_in; 
    END IF;
  END PROCESS;

  double : process (clk)
  begin
     If rising_edge(clk) then
	  w_en <= w_en_inter;
	  wr <= wr_inter;
     end if;
     end process;
END ARCHITECTURE;
