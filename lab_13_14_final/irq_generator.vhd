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

entity irq_generator is
Port ( 
    clk, irq_ack,reset : in std_logic; 
    irq_output : out std_logic
);
end irq_generator;

architecture Behavioral of irq_generator is
signal counter : integer := 0;
signal output_signal: std_logic := '0';
signal irq_ack_signal : std_logic;

begin
process(clk)
begin
    if rising_edge(clk) then
        if irq_ack_signal = '1' or reset = '1' then
            counter <= 0; 
            output_signal <= '0';
        else
            counter <= counter + 1;
            if (counter = 200000) then
                counter <= 0;
                output_signal <= not output_signal;
            end if;
        end if;
    end if; 
end process;

irq_ack_signal <= irq_ack;
irq_output <= output_signal;
end Behavioral;
