----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2019 04:46:39 PM
-- Design Name: 
-- Module Name: ALU_and_flags - Behavioral
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
use ieee.std_logic_signed.all;
use work.common_type.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_and_flags is
  Port ( op_1: in std_logic_vector(31 downto 0);
         op_2: in std_logic_vector(31 downto 0);
         carry,s_bit: in std_logic;
         carry_from_shifter : in std_logic;
         op_to_be_performed :in alu_op_type;
         shift_amount :in std_logic_vector(4 downto 0);
         wea: in std_logic;
         z_flag_output,n_flag_output,v_flag_output,c_flag_output: out std_logic;
         result:out std_logic_vector(31 downto 0)
   );
end ALU_and_flags;

architecture Behavioral of ALU_and_flags is
signal z_flag,v_flag,c_flag,n_flag,c_32,c_31:std_logic;
signal res_temp:std_logic_vector(31 downto 0);
begin
result <= res_temp;
c_31 <= op_1(31) xor op_2(31) xor res_temp(31);
c_32 <= (op_1(31) AND op_2(31)) or (op_1(31) and c_31) or(op_2(31) and c_31); 
res_temp <= std_logic_vector(signed(op_1)) AND std_logic_vector(signed(op_2)) when ( op_to_be_performed = op_and )
       ELSE std_logic_vector(signed(op_1)) XOR std_logic_vector(signed(op_2)) when ( op_to_be_performed = op_xor )
       else std_logic_vector(signed(op_1)) - std_logic_vector(signed(op_2)) when ( op_to_be_performed = sub )       
       else (not(std_logic_vector(signed(op_1)))) + std_logic_vector(signed(op_2)) + 1 when ( op_to_be_performed = rsb )       
       else std_logic_vector(signed(op_1)) + std_logic_vector(signed(op_2)) + carry when ( op_to_be_performed = add ) -- This add will also be used to increment PC in fetch and branch instruction       
       else std_logic_vector(signed(op_1)) + std_logic_vector(signed(op_2)) + c_flag when ( op_to_be_performed = adc )       
       else std_logic_vector(signed(op_1)) + (not(std_logic_vector(signed(op_2)))) + c_flag when ( op_to_be_performed = sbc )       
       else (not(std_logic_vector(signed(op_1)))) + std_logic_vector(signed(op_2)) + c_flag when ( op_to_be_performed = rsc )       
       else std_logic_vector(signed(op_1)) OR std_logic_vector(signed(op_2)) when ( op_to_be_performed = orr )       
       else std_logic_vector(signed(op_1)) AND (not(std_logic_vector(signed(op_2)))) when ( op_to_be_performed = bic )       
       else (not(std_logic_vector(signed(op_2)))) when ( op_to_be_performed = mvn )       
       else std_logic_vector(signed(op_2)) when ( op_to_be_performed = mov );       
z_flag <= '1' when res_temp = X"00000000" AND s_bit = '1' and wea ='1'
       else '0' when (not(res_temp = X"00000000")) and s_bit = '1' and wea ='1';
n_flag <= res_temp(31) when s_bit = '1' and wea ='1';   
c_flag <= c_32 when (s_bit = '1' and wea ='1' and (op_to_be_performed = sub or op_to_be_performed = rsb or op_to_be_performed = add or op_to_be_performed = adc or op_to_be_performed = sbc or op_to_be_performed = rsc))
              else carry_from_shifter when s_bit = '1' and not(shift_amount = "00000") and wea ='1';
v_flag <= (c_32 xor c_31) when s_bit = '1' and wea ='1';         
z_flag_output <= z_flag;       
c_flag_output <= c_flag;       
n_flag_output <= n_flag;       
v_flag_output <= v_flag;       
end Behavioral;