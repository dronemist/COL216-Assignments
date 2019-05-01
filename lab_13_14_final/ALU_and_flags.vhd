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
  Port ( 
		 clk: in std_logic;
		 op_1: in std_logic_vector(31 downto 0);
         op_2: in std_logic_vector(31 downto 0);
         op_3: in std_logic_vector(63 downto 0);
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
signal z_flag,v_flag,c_flag,n_flag,c_32,c_31:std_logic := '0';
signal op_1_signal, op_2_signal : std_logic_vector(31 downto 0);
signal res_temp:std_logic_vector(31 downto 0);
begin
op_1_signal <= not(op_1) when op_to_be_performed = rsb or op_to_be_performed = rsc
                else op_1;
                
op_2_signal <= not(op_2) when op_to_be_performed = sub or op_to_be_performed = sbc or op_to_be_performed = bic or op_to_be_performed = mvn or op_to_be_performed = mvn
                else op_2;
result <= res_temp;
c_31 <= op_1_signal(31) xor op_2_signal(31) xor res_temp(31);
c_32 <= (op_1_signal(31) AND op_2_signal(31)) or (op_1_signal(31) and c_31) or(op_2_signal(31) and c_31); 
res_temp <= std_logic_vector(signed(op_1)) AND std_logic_vector(signed(op_2)) when ( op_to_be_performed = op_and )
       ELSE std_logic_vector(signed(op_1)) XOR std_logic_vector(signed(op_2)) when ( op_to_be_performed = op_xor )
       else std_logic_vector(signed(op_1)) + (not std_logic_vector(signed(op_2))) + 1 when ( op_to_be_performed = sub )       
       else (not(std_logic_vector(signed(op_1)))) + std_logic_vector(signed(op_2)) + 1 when ( op_to_be_performed = rsb )       
       else std_logic_vector(signed(op_1)) + std_logic_vector(signed(op_2)) + carry when ( op_to_be_performed = add ) -- This add will also be used to increment PC in fetch and branch instruction       
       else std_logic_vector(signed(op_1)) + std_logic_vector(signed(op_2)) + c_flag when ( op_to_be_performed = adc )       
       else std_logic_vector(signed(op_1)) + (not(std_logic_vector(signed(op_2)))) + c_flag when ( op_to_be_performed = sbc )       
       else (not(std_logic_vector(signed(op_1)))) + std_logic_vector(signed(op_2)) + c_flag when ( op_to_be_performed = rsc )       
       else std_logic_vector(signed(op_1)) OR std_logic_vector(signed(op_2)) when ( op_to_be_performed = orr )       
       else std_logic_vector(signed(op_1)) AND (not(std_logic_vector(signed(op_2)))) when ( op_to_be_performed = bic )       
       else (not(std_logic_vector(signed(op_2)))) when ( op_to_be_performed = mvn )       
       else std_logic_vector(signed(op_2)) when ( op_to_be_performed = mov );       
-- z_flag <= '1' when ((res_temp = X"00000000" and not(op_to_be_performed = mul)) or (op_3 = x"0000000000000000" and op_to_be_performed = mul)) AND s_bit = '1' and wea ='1'
       -- else '0' when ((not(res_temp = X"00000000") and not(op_to_be_performed = mul)) OR (not(op_3 = x"0000000000000000") and op_to_be_performed = mul)) and s_bit = '1' and wea ='1';
-- n_flag <= (res_temp(31)) when s_bit = '1' and wea = '1' and not(op_to_be_performed = mul)
            -- else op_3(63) when s_bit = '1' and wea = '1' and op_to_be_performed = mul;   
-- c_flag <= c_32 when (s_bit = '1' and wea ='1' and (op_to_be_performed = sub or op_to_be_performed = rsb or op_to_be_performed = add or op_to_be_performed = adc or op_to_be_performed = sbc or op_to_be_performed = rsc))
              -- else carry_from_shifter when s_bit = '1' and not(shift_amount = "00000") and wea ='1' and not(op_to_be_performed = mul);
-- v_flag <= (c_32 xor c_31) when s_bit = '1' and wea ='1' and not(op_to_be_performed = mul); 

process(clk)
begin
	if rising_edge(clk) then
		if s_bit = '1' and wea = '1' then
			
		
			if (op_to_be_performed = mul) then
				if op_3 = x"0000000000000000" then
					z_flag <= '1';
				else
					z_flag <= '0';
				end if;
				n_flag <= op_3(63);
			else
				if res_temp = X"00000000" then
					z_flag <= '1';
				else	
					z_flag <= '0';					
				end if;
				n_flag <= res_temp(31);
				v_flag <= (c_32 xor c_31);
				if (op_to_be_performed = sub or op_to_be_performed = rsb or op_to_be_performed = add or op_to_be_performed = adc or op_to_be_performed = sbc or op_to_be_performed = rsc) then
					c_flag <= c_32;
				else 
					if not(shift_amount = "00000") then
						c_flag <= carry_from_shifter;
					end if;
				end if;
			end if;
			
		end if;
	end if;
end process;
        
z_flag_output <= z_flag;       
c_flag_output <= c_flag;       
n_flag_output <= n_flag;       
v_flag_output <= v_flag;       
end Behavioral;