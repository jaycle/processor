library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity decoder is
  port( clk: in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        rdx,rdy,wr,alu_op,alu_sel : out std_logic_vector (3 downto 0);
        imData : out std_logic_vector (7 downto 0);
        ry_im,sel_dmem,wr_en,jump_en : out std_logic
      );
      
    end entity;
    
architecture behav of decoder is
  
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
  
  process(instruction,clk)
    
    begin
      
      
      --if clk'event and clk='1' then     this is to try to get clock for interrupt working
      case op is
        
        when no_op =>
        jump_en <= '0';
        wr_en <='0';
        ry_im<='0';
        sel_dmem<='0';
        alu_op <= instruction(15 downto 12);
        alu_sel <= instruction (11 downto 8); 
        wr <= instruction(3 downto 0);
        rdx <= instruction(3 downto 0);
        rdy <= instruction(7 downto 4); 
        imData <=instruction(7 downto 0);
        
      
        when "0001" =>
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '1';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);   
          wr <= instruction(11 downto 8);
          imData <=instruction(7 downto 0);
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4); 
          
        when add_sub =>
          jump_en <= '0'; 
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4); 
          
        
        when inc_dec =>
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4); 
          
        when shift => 
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        when alu_logic =>
          
          if (instruction (11 downto 8) ="1000" ) then
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(7 downto 4);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        else
          jump_en <= '0';
          wr_en <='1';
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
          
          
        when load_indirect =>
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
          
        when store_indirect =>
          jump_en <= '0';
          wr_en <='0';
          ry_im <= '0';
          sel_dmem <= '1';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        when  load_reg =>
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(11 downto 8);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(11 downto 8);
          rdy <= instruction(7 downto 4);
          
        when store_reg =>
          jump_en <= '0';
          wr_en <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(11 downto 8);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(11 downto 8);
          rdy <= instruction(7 downto 4);
          
        when jump =>
          jump_en <= '1';
          wr_en <='0';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
        when branch_zero =>
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
          
        when branch_notzero =>
          jump_en <= '0';
          wr_en <='1';
          ry_im <= '0';
          sel_dmem <= '0';
          alu_op <= instruction(15 downto 12);
          alu_sel <= instruction (11 downto 8);  
          wr <= instruction(3 downto 0);
          imData <=instruction(7 downto 0); 
          rdx <= instruction(3 downto 0);
          rdy <= instruction(7 downto 4);
          
          
        --when  return_interupt
          
      when others => null;
        
      end case;
      
   -- end if;  for interrupts
      
      
    end process;
    
    
  end behav;
