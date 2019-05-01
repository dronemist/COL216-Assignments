----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 01:23:02 PM
-- Design Name: 
-- Module Name: execution_state_FSM - Behavioral
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
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity execution_state_FSM is
Port ( 
    step,instr,go,reset,clk:in std_logic;
    control_state:in control_state_type;
    red_flag : in std_logic;
    execution_state: out execution_state_type;
    green_flag: out std_logic
);
end execution_state_FSM;

architecture Behavioral of execution_state_FSM is
signal curr_mode : execution_state_type:=initial;
begin
green_flag <= '1' when curr_mode = onestep or curr_mode = oneinstr or curr_mode = cont
else '0'; 
--mode type process
Process(clk,reset)
begin
    if(reset = '1') then
        curr_mode <= initial;
    elsif(rising_edge(clk)) then
        case curr_mode is
            when initial => 
                if step = '1' then 
                    curr_mode <= onestep;
                elsif go = '1' then
                    curr_mode <= cont;
                elsif instr = '1' then
                    curr_mode <= oneinstr;    
                end if;
           when onestep =>
                curr_mode <= done;
           when oneinstr =>
                if red_flag = '1' then
                    curr_mode <= done;
                end if;     
           when cont => 
                if control_state = halt then
                    curr_mode <= done;
                end if;
           when done => 
                if step='0' and go ='0' and instr='0' then
                    curr_mode <= initial;
                end if;
       end case;                                   
    end if;     
end process;
execution_state <= curr_mode;
end Behavioral;
