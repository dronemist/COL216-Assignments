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
ENTITY dec4_16 IS
    PORT(S: IN std_logic_vector(3 DOWNTO 0);
        Y: OUT std_logic_vector(15 DOWNTO 0));
END dec4_16;

ARCHITECTURE ssa of dec4_16 is
begin
with s select
    Y <= "0000000000000001" WHEN "0000",
     "0000000000000010" WHEN "0001",
     "0000000000000100" WHEN "0010",
     "0000000000001000" WHEN "0011",
     "0000000000010000" WHEN "0100",
     "0000000000100000" WHEN "0101",
     "0000000001000000" WHEN "0110",
     "0000000010000000" WHEN "0111",
     "0000000100000000" WHEN "1000",
     "0000001000000000" WHEN "1001",
     "0000010000000000" WHEN "1010",
     "0000100000000000" WHEN "1011",
     "0001000000000000" WHEN "1100",
     "0010000000000000" WHEN "1101",
     "0100000000000000" WHEN "1110",
     "1000000000000000" WHEN "1111";

END ARCHITECTURE ssa;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
ENTITY Bin2SevenSeg IS
   PORT (Bin: IN std_logic_vector(3 DOWNTO 0);
         SS: OUT std_logic_vector(6 DOWNTO 0)  );
END Bin2SevenSeg;

ARCHITECTURE struct OF Bin2SevenSeg IS
 SIGNAL Y : std_logic_vector(15 DOWNTO 0);
BEGIN
    D : ENTITY work.dec4_16 (ssa) PORT MAP (Bin, Y);
    SS(0) <= Y(1) or Y(4) or Y(11) or Y(13);
    SS(1) <= Y(5) or Y(6) or Y(11) or Y(12) or Y(14) or Y(15);
    SS(2) <= Y(2) or Y(12) or Y(14) or Y(15);
    SS(3) <= Y(1) or Y(4) or Y(7) or Y(10) or Y(15);
    SS(4) <= Y(1) or Y(3) or Y(4) or Y(5) or Y(7) or Y(9);
    SS(5) <= Y(1) or Y(2) or Y(3) or Y(7) or Y(13);
    SS(6) <= Y(0) or Y(1) or Y(7) or Y(12);
END ARCHITECTURE struct;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
entity display IS -- Divides the 16 bits to be displayed into 4
    PORT(
        Num_to_be_displayed : IN std_logic_vector(15 downto 0);
        anode_pattern : IN std_logic_vector(3 downto 0);
        cathode_output : OUT std_logic_vector(6 downto 0);
        anode_output : OUT std_logic_vector(3 downto 0)
    );
end display;

architecture behavorial of display is
    signal digit_to_be_displayed : std_logic_vector(3 downto 0);
begin
    F : ENTITY work.Bin2SevenSeg (struct) PORT MAP (Bin => digit_to_be_displayed, SS => cathode_output);
    digit_to_be_displayed <= Num_to_be_displayed(15 downto 12) when anode_pattern = "0111"
                            else Num_to_be_displayed(11 downto 8) when anode_pattern = "1011"
                            else Num_to_be_displayed(7 downto 4) when anode_pattern = "1101"
                            else Num_to_be_displayed(3 downto 0) when anode_pattern = "1110"
                            else "0000";
    anode_output <= anode_pattern;
end architecture display_arch;
