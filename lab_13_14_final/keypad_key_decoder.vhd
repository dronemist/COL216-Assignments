----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2019 03:59:40 PM
-- Design Name: 
-- Module Name: display - Behavioral
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
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
ENTITY keypad_key_decoder IS
    PORT(
		clk : IN std_logic;
		keypad_driver : IN std_logic_vector(3 DOWNTO 0);
        keypad_row : IN std_logic_vector(3 DOWNTO 0);
		key_pressed : OUT std_logic;
		keypad_key_decoded : OUT std_logic_vector(3 downto 0)
		);
END keypad_key_decoder;        

ARCHITECTURE behavorial of keypad_key_decoder is
signal key_pressed_signal : std_logic := '0';
begin
key_pressed <= key_pressed_signal;
process(clk)
begin
	if(rising_edge(clk)) then 
		key_pressed_signal <= '1';
		case keypad_row is
			when "0111" => 
							case keypad_driver IS
								when "1110" => keypad_key_decoded <= x"A"; 
								when "0111" => keypad_key_decoded <= x"1";
								when "1011" => keypad_key_decoded <= x"2";
								when "1101" => keypad_key_decoded <= x"3";
								when others => -- do nothing
							end case;
						
							
			when "1011" => 
							case keypad_driver IS
								when "1110" => keypad_key_decoded <= x"B"; 
								when "0111" => keypad_key_decoded <= x"4";
								when "1011" => keypad_key_decoded <= x"5";
								when "1101" => keypad_key_decoded <= x"6";
								when others => -- do nothing
							end case;
							
							
			when "1101" =>
							case keypad_driver IS
								when "1110" => keypad_key_decoded <= x"C"; 
								when "0111" => keypad_key_decoded <= x"7";
								when "1011" => keypad_key_decoded <= x"8";
								when "1101" => keypad_key_decoded <= x"9";
								when others => -- do nothing
							end case;
							
							
			when "1110" => 	case keypad_driver IS
								when "1110" => keypad_key_decoded <= x"D"; 
								when "0111" => keypad_key_decoded <= x"0";
								when "1011" => keypad_key_decoded <= x"F";
								when "1101" => keypad_key_decoded <= x"E";
								when others => -- do nothing
							end case;
			when "1111" =>  key_pressed_signal <= '0';
			when others => -- do nothing
		end case;
	
	end if;

end process;
    
END ARCHITECTURE behavorial;