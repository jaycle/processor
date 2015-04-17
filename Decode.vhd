library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity decode is
  port( clk, z_flg: in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        rdx,rdy,wr,alu_op,alu_sel : out std_logic_vector (3 downto 0);
        imData, offset, jump_addr : out std_logic_vector (7 downto 0);
        ry_im, -- Selects immediate when 1, ry when zero for ALU
		sel_dmem, -- selects address. 1 : Rx, 0 : Imm
		wb_sel, -- selects writeback data. 1 : DMEM, 0 : ALU out
		jump_en, 
		w_en,  -- register write enable
		branch_en : out std_logic
      );
    end entity;
    

architecture behav of decode is
  
  -- signals
  signal op : std_logic_vector(3 downto 0);
  signal sel : std_logic_vector(3 downto 0);
  
  -- states listed as constants
  
  constant no_op : std_logic_vector := "0000";
  constant add_im : std_logic_vector := "0001";
  constant add_sub : std_logic_vector := "0010";
  constant inc_dec : std_logic_vector := "0011";
  constant shift : std_logic_vector := "0100";
  constant alu_logic : std_logic_vector := "0101";
  constant en_intrupts : std_logic_vector := "0111";
  constant load_indirect : std_logic_vector := "1000";
  constant store_indirect : std_logic_vector := "1001";
  constant load_reg : std_logic_vector := "1010";
  constant store_reg : std_logic_vector := "1011";
  constant jump : std_logic_vector := "1100";
  constant branch_zero : std_logic_vector := "1101";
  constant branch_notzero : std_logic_vector := "1110";

  
begin
  
  
	op <= instruction(15 downto 12);
	sel <= instruction (11 downto 8);
  
	process(instruction)
	begin
--	if (rising_edge(clk)) then

	-- default outputs
	branch_en <= '0';
	offset <= "00000000";
	jump_addr <= "00000000";
	jump_en <= '0';
	w_en <= '0';
    wb_sel <='0';
    ry_im<='0';
    sel_dmem<='0';
	
	case op is
        
    when no_op =>
		w_en <= '0';
        jump_en <= '0';
        wb_sel <='0';
        ry_im<='0';
        sel_dmem<='0';
        alu_op <= instruction(15 downto 12);
        alu_sel <= instruction (11 downto 8); 
        wr <= instruction(3 downto 0);
        rdx <= instruction(3 downto 0);
        rdy <= instruction(7 downto 4); 
        imData <=instruction(7 downto 0);
        
      
	when add_im =>
		  w_en <= '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '1';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);   
          wr <= instruction(11 downto 8);
          imData <=instruction(7 downto 0);
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4); 
          
        when add_sub =>
		  w_en <= '1';
          jump_en <= '0'; 
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4); 
          
        
        when inc_dec =>
		  w_en <= '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4); 
          
        when shift =>
     	  w_en <= '0'; 
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        when alu_logic =>
          
          if (instruction (11 downto 8) ="1000" ) then  -- MOV instruction
		  w_en <= '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(7 downto 4);  -- select Ry as write address
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        else
		  w_en <= '1';   
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
          
        end if;
        
       -- when en_interupts =>
          
          
        when load_indirect =>  -- R[x] <= MEM[Ry]
		  w_en <= '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '1';  
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);   --Rx
          imData <=instruction(7 downto 0); 
          rdx <= instruction(7 downto 4);  -- actually Ry b/c dumb ISA
          rdy <= instruction(7 downto 4);
          
          
        when store_indirect =>
		  w_en <= '0';
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        when  load_reg =>
		  w_en <= '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';  -- selects imData
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(11 downto 8);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(11 downto 8);
          rdy <= instruction(7 downto 4);
          
        when store_reg =>
		  w_en <= '0';
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';  -- select ImData
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(11 downto 8);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(11 downto 8);
          rdy <= instruction(11 downto 8);
          
        when jump =>
		  w_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          jump_en <= '1';
		  jump_addr <= instruction(7 downto 0);
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        when branch_zero =>
		  w_en <= '0';
          jump_en <= '0';
          wb_sel <='1';	
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
			if (z_flg = '0') then
				branch_en <= '1';
				offset <= instruction(7 downto 0);
			end if;
          
          
        when branch_notzero =>
		  w_en <= '0';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
			if (z_flg = '1') then
				branch_en <= '1';
				offset <= instruction(7 downto 0);
			end if;
          
          
        --when  return_interupt
          
      when others => null; 
		-- same output as nop
		w_en <= '0';
        jump_en <= '0';
        wb_sel <='0';
        ry_im<='0';
        sel_dmem<='0';
        alu_op <= instruction(15 downto 12);
        alu_sel <= instruction (11 downto 8); 
        wr <= instruction(3 downto 0);
        rdx <= instruction(3 downto 0);
        rdy <= instruction(7 downto 4); 
        imData <=instruction(7 downto 0);
        
      end case;
      
--	end if; -- clk edge
      
      
    end process;
    
    
  

end behav;
