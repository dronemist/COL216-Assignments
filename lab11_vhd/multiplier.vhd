----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2019 03:05:22 PM
-- Design Name: 
-- Module Name: multiplier - Behavioral
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

entity multiplier is
Port (
       op_1: in std_logic_vector(31 downto 0);
       op_2: in std_logic_vector(31 downto 0);
       is_signed: in std_logic;
       mul_result: out std_logic_vector(63 downto 0)
 );
end multiplier;

architecture Behavioral of multiplier is
    signal operand1_33, operand2_33 : std_logic_vector (32 downto 0);
    signal a_s, b_s : signed (32 downto 0);     
    signal p_s : signed (65 downto 0); 
    signal a_u, b_u : unsigned (31 downto 0);     
    signal p_u : unsigned (63 downto 0); 
    signal x1: std_logic;
    signal x2: std_logic;
begin
x1 <= op_1(31) when is_signed = '1' else '0';
x2 <= op_2(31) when is_signed = '1' else '0';
operand1_33 <= x1 & op_1; 
operand2_33 <= x2 & op_2; 
a_s <= signed (operand1_33); 
b_s <= signed (operand2_33); 
p_s <= a_s * b_s; 
mul_result <= std_logic_vector(p_s(63 downto 0)); 
--    p_s <= a_s * b_s;
--    p_u <= a_u * b_u; 
end Behavioral;
