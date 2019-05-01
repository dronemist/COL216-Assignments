----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2019 02:52:01 PM
-- Design Name: 
-- Module Name: irq_generator - Behavioral
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

entity keypad_driver_generator is
Port ( 
    clk : in std_logic; 
    keypad_driver_output : out std_logic_vector(3 downto 0)
);
end keypad_driver_generator;

architecture Behavioral of keypad_driver_generator is
signal counter : integer := 0;
signal output_signal: std_logic_vector(3 downto 0) := "1110";

begin
process(clk)
begin
    if rising_edge(clk) then       
		counter <= counter + 1;
		if (counter = 200000) then
			counter <= 0;
			case output_signal is
				when "1110" => output_signal <= "0111";
				when "0111" => output_signal <= "1011";
				when "1011" => output_signal <= "1101";
				when "1101" => output_signal <= "1110";
				when others => -- do nothing
			end case;
		end if;
    end if; 
end process;

keypad_driver_output <= output_signal;
end Behavioral;
