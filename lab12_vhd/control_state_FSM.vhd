----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 02:10:11 PM
-- Design Name: 
-- Module Name: control_state_FSM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.common_type.all;
use ieee.std_logic_signed.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_state_FSM is
Port ( 
    instr_class : in instr_class_type;
    reset,ld_bit,green_flag,clk :in std_logic;
    red_flag : out std_logic;
    predicate_bit:in std_logic;
    control_state: out control_state_type
);
end control_state_FSM;

architecture Behavioral of control_state_FSM is
signal curr_control_state : control_state_type;
begin
control_state <= curr_control_state;
red_flag <= '1' when  curr_control_state = mem_wr or curr_control_state = halt or curr_control_state = skip
else '0';
-- control_state state transitions
process(clk,reset)
begin
    if reset = '1' then
        curr_control_state <= fetch;
    elsif rising_edge(clk) then
        if green_flag = '1' then
            case curr_control_state is
                when fetch => 
                    curr_control_state <= decode;
                when decode =>
                 if instr_class = halt then
                      curr_control_state <= halt;
                 elsif predicate_bit = '0' then
                       curr_control_state <= skip;
                 else    
                        if instr_class = DP then
                            curr_control_state <= decode_shift;
                        elsif instr_class = DP_mull then
                            curr_control_state <= mult;    
                        elsif instr_class = DT then
                            curr_control_state <= decode_shift;
                        elsif instr_class = branch then
                            curr_control_state <= brn;        
						elsif instr_class = swi or instr_class = unknown then
							curr_control_state <= exception_handler;
                        end if;
                end if;
                when skip =>
                    curr_control_state <= fetch;
                when mult =>
                    curr_control_state <= alu_mult;                
                when alu_mult =>
                    curr_control_state <= res2RF_1;
                when res2RF_1 =>
                    curr_control_state <= res2RF_2;
                when res2RF_2 =>
                    curr_control_state <= skip;                
                when decode_shift =>
                    if instr_class = DP then
                        curr_control_state <= arith;
                     elsif instr_class = DT then
                        curr_control_state <= addr;
                     end if;    
                when arith =>
                    curr_control_state <= res2RF;
                when res2RF =>
                    curr_control_state <= skip;
                when addr =>
                    if ld_bit = '1' then
                        curr_control_state <= mem_rd;
                    else
                        curr_control_state <= mem_wr;
                    end if;
                when mem_wr =>
                    curr_control_state <= fetch;
                when mem_rd =>
                    curr_control_state <= mem2RF;
                when mem2RF =>
                    curr_control_state <= skip;
                when brn =>
                    curr_control_state <= skip;
                when halt =>
                    curr_control_state <= fetch;    
				when exception_handler =>
					curr_control_state <= skip;
            end case;
        end if;        
    end if;        
end process;
end Behavioral;