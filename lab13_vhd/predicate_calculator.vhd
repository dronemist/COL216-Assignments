----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2019 05:41:14 PM
-- Design Name: 
-- Module Name: predicate_calculator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity predicate_calculator is
  Port (
  z_flag,n_flag,c_flag,v_flag: in std_logic;
  ins: in std_logic_vector(3 downto 0);
  predicate: out std_logic
  
   );
end predicate_calculator;

architecture Behavioral of predicate_calculator is

begin
predicate <= z_flag when ins = "0000"
            else (not z_flag) when ins = "0001"
            else (c_flag) when ins = "0010"
            else (not c_flag) when ins = "0011"
            else (n_flag) when ins = "0100"
            else (not n_flag) when ins = "0101"
            else (v_flag) when ins = "0110"
            else (not v_flag) when ins = "0111"
            else (c_flag and not z_flag) when ins = "1000"
            else (not (c_flag and not z_flag)) when ins = "1001"
            else (not (v_flag xor n_flag)) when ins = "1010"
            else (v_flag xor n_flag) when ins = "1011"
            else ((not (v_flag xor n_flag)) and not z_flag) when ins = "1100"
            else (not ((not (v_flag xor n_flag)) and not z_flag)) when ins = "1101"
            else '1' when ins = "1110";
end Behavioral;
