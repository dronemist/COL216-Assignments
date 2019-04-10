----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2019 04:19:27 PM
-- Design Name: 
-- Module Name: adder_64_bit - Behavioral
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

entity adder_64_bit is
Port (
       op_1: in std_logic_vector(63 downto 0);
       op_2: in std_logic_vector(63 downto 0);
       is_signed: in std_logic;
       add_result: out std_logic_vector(63 downto 0)
 );
end adder_64_bit;

architecture Behavioral of adder_64_bit is

begin
add_result <= std_logic_vector((signed(op_1) + signed(op_2))) when is_signed = '1'
              else std_logic_vector((unsigned(op_1) + unsigned(op_2)));

end Behavioral;
