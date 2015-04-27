library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

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
		branch_en : out std_logic;
		clr_1,  				-- IF/ID register
		clr_2,  				-- ID/EX register
		clr_3 : out std_logic   -- EX/WB register
      );
    end entity;
    

architecture behav of decode is
  
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

-- signal declarations
 
	signal w_en_internal : std_logic;
	signal wr_internal : std_logic_vector(3 downto 0);

	type data is array(0 to 2) of std_logic_vector(4 downto 0);  -- MSB is hazard, 3 downto 0 is address
    signal reg : data := (others => (others => '0'));  -- holds hazards and address
  
begin

  
	decode : process(instruction)
	-- variable declarations 
	variable op : std_logic_vector(3 downto 0);
    variable sel : std_logic_vector(3 downto 0);
	variable stall : natural range 0 to 2 := 0; -- stall length for hazard

	variable w_en_sig : std_logic;
	variable wr_sig : std_logic_vector(3 downto 0);
	variable rdx_sig : std_logic_vector(3 downto 0);
	variable rdy_sig : std_logic_vector(3 downto 0); 

	begin

	-- default outputs
	branch_en <= '0';
	offset <= "00000000";
	jump_addr <= "00000000";
	jump_en <= '0';
	w_en_sig := '0';
    wb_sel <='0';
    ry_im<='0';
    sel_dmem<='0';
	clr_1 <= '0';
	clr_2 <= '0';        
	clr_3 <= '0';

	-- variable (re)assignment
	op := instruction(15 downto 12);
	sel := instruction (11 downto 8);

	
	case op is
        
    when no_op =>
		w_en_sig := '0';
        jump_en <= '0';
        wb_sel <='0';
        ry_im<='0';
        sel_dmem<='0';
        alu_op <= instruction(15 downto 12);
        alu_sel <= instruction (11 downto 8); 
       wr_sig:= instruction(7 downto 4);
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
        imData <=instruction(7 downto 0);
		clr_1 <= '0';
		clr_2 <= '0';        
		clr_3 <= '0';
      
	when add_im =>
		  w_en_sig := '1';
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '1';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);   
         wr_sig:= instruction(11 downto 8);
          imData <=instruction(7 downto 0);
          rdx_sig := instruction(11 downto 8);
          rdy_sig := instruction(7 downto 4); 
          
        when add_sub =>
		  w_en_sig := '1';
          jump_en <= '0'; 
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(7 downto 4);
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4); 
          
        
        when inc_dec =>
		  w_en_sig := '1';
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(7 downto 4);
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
          
        when shift =>
     	  w_en_sig := '0'; 
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(7 downto 4);
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
          
        when alu_logic =>
          
          if (instruction (11 downto 8) ="1000" ) then  -- MOV instruction
		  w_en_sig := '1';
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(3 downto 0);  -- select Ry as write address
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
          
        else
		  w_en_sig := '1';   
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
		 wr_sig:= instruction(7 downto 4); -- Rx is write as usual
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
          
          
        end if;
        
       -- when en_interupts =>
          
          
        when load_indirect =>  -- R[x] <= MEM[Ry]
		  w_en_sig := '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '1';  
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(7 downto 4);   --Rx
          imData <=instruction(7 downto 0); 
          rdx_sig := instruction(7 downto 4);  -- actually Ry b/c dumb ISA
          rdy_sig := instruction(7 downto 4);
          
          
        when store_indirect =>
		  w_en_sig := '0';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(7 downto 4);
          imData <=instruction(7 downto 0); 
          rdx_sig := instruction(3 downto 0);
          rdy_sig := instruction(7 downto 4);
          
        when  load_reg =>
		  w_en_sig := '1';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';  -- selects imData
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(11 downto 8);
          imData <=instruction(7 downto 0); 
          rdx_sig := instruction(11 downto 8);
          rdy_sig := instruction(7 downto 4);
          
        when store_reg =>
		  w_en_sig := '0';
          jump_en <= '0';
          wb_sel <='1';
          ry_im <= '0';
          sel_dmem <= '0';  -- select ImData
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(11 downto 8);
          imData <=instruction(7 downto 0); 
          rdx_sig := instruction(11 downto 8);
          rdy_sig := instruction(11 downto 8);
          
        when jump =>
		  w_en_sig := '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          jump_en <= '1';
		  jump_addr <= instruction(7 downto 0);
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
		  clr_1 <= '1';   -- clear previous instruction
          
        when branch_zero =>
		  w_en_sig := '0';
          jump_en <= '0';
          wb_sel <='0';	
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
			if (z_flg = '0') then
				branch_en <= '1';
				offset <= instruction(7 downto 0);
			end if;
          
          
        when branch_notzero =>
		  w_en_sig := '0';
          jump_en <= '0';
          wb_sel <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
         wr_sig:= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdy_sig := instruction(3 downto 0);
          rdx_sig := instruction(7 downto 4);
			if (z_flg = '1') then
				branch_en <= '1';
				offset <= instruction(7 downto 0);
			end if;
          
          
        --when  return_interupt
          
      when others => null; 
		-- same output as nop
		w_en_sig := '0';
        jump_en <= '0';
        wb_sel <='0';
        ry_im<='0';
        sel_dmem<='0';
        alu_op <= instruction(15 downto 12);
        alu_sel <= instruction (11 downto 8); 
        wr_sig:= instruction(3 downto 0);
        rdy_sig := instruction(3 downto 0);
        rdx_sig := instruction(7 downto 4); 
        imData <=instruction(7 downto 0);
        
      end case;

	w_en_internal <= w_en_sig;
	wr_internal <= wr_sig;

-------------- End decode section -----------------



-------------- begin haz check section ------------
	

	-- get stall length based upon hazard location in pipeline
		if (stall = 0) then
			if (reg(1)(4) = '1') then
				if (rdx_sig = reg(1)(3 downto 0) or (rdy_sig = reg(1)(3 downto 0))) then
					stall := 2;
				end if;
			elsif (reg(0)(4) = '1') then
				if (rdx_sig = reg(0)(3 downto 0) or (rdy_sig = reg(0)(3 downto 0))) then
					stall := 1;
				end if;
			else
				stall := 0;
		    end if;
		end if;
		
		-- Take action based upon detected hazards
		if (stall = 0) then
			-- no hazards. Update outputs as normal
			w_en <= w_en_sig;
			wr <= wr_sig;
			rdx <= rdx_sig;
			rdy <= rdy_sig;
		else
			branch_en <= '1';
			offset <= std_logic_vector(to_signed(-stall, offset'length));
			stall := stall - 1;
				-- zeros down pipeline
			wr <= (others => '0');
			w_en <= '0';
			rdx <= (others => '0');
			rdy <= (others => '0');
	        sel_dmem<= '0';
	        alu_op <= (others => '0');
	        alu_sel <= (others => '0');
			wr_sig := (others => '0');
	        rdy_sig := (others => '0');
	        rdx_sig := (others => '0');
	        imData <= (others => '0');
			   -- clear previous instruction too
			clr_1 <= '1';
		end if;

    end process;


	-- process which updates haz register each clock cycle regardless of instruction change
	haz_update : process(clk) is
	begin
	if (rising_edge(clk)) then  
		-- move hazards down through register
		reg(0) <= reg(1);
		reg(1) <= reg(2);
		reg(2) <= w_en_internal & wr_internal;  -- 1 in MSB denotes register expects to be written
	end if;
	end process;
	    			
  

end behav;
