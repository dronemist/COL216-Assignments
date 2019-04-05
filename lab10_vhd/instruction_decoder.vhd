----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2019 01:52:22 PM
-- Design Name: 
-- Module Name: instruction_decoder - Behavioral
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

entity instruction_decoder is
Port ( 
  instruction :in std_logic_vector(31 downto 0);
  instr_class : out instr_class_type;
  i_decoded : out i_decoded_type
);
end instruction_decoder;

architecture Behavioral of instruction_decoder is
signal F_field:std_logic_vector(1 downto 0);
signal P_bit,B_bit,W_bit,I_bit,S_bit,L_bit : std_logic;
signal opcode,cond : std_logic_vector(3 downto 0);
signal opc : std_logic_vector(1 downto 0);
signal sh : std_logic_vector(1 downto 0);
signal instr_class_signal:instr_class_type;
begin
sh <= instruction(6 downto 5); 
F_field <= instruction(27 downto 26);
P_bit <= instruction(24);
B_bit <= instruction(22);
W_bit <= instruction(21);
I_bit <= instruction(25);
L_bit <= instruction(20);
S_bit <= instruction(20);
opcode <= instruction(24 downto 21);
cond <= instruction(31 downto 28);
opc <= instruction(25 downto 24);
instr_class <= instr_class_signal;  
instr_class_signal <= halt when instruction = X"00000000"
               else DT when F_field = "01" or (F_field = "00" and I_bit = '0' and instruction(7) = '1' and (not(instruction(6 downto 5) = "00")) and instruction(4) = '1') 
               else DP when F_field = "00"
               else branch when F_field = "10"
               else unknown;               
i_decoded <= 
    and_instr when instr_class_signal = DP and opcode = "0000"
    else eor when instr_class_signal = DP and opcode = "0001"
    else sub when instr_class_signal = DP and opcode = "0010"
    else rsb when instr_class_signal = DP and opcode = "0011"
    else add when instr_class_signal = DP and opcode = "0100"
    else adc when instr_class_signal = DP and opcode = "0101"
    else sbc when instr_class_signal = DP and opcode = "0110"
    else rsc when instr_class_signal = DP and opcode = "0111"
    else tst when instr_class_signal = DP and opcode = "1000" and S_bit = '1'
    else teq when instr_class_signal = DP and opcode = "1001" and S_bit = '1'
    else cmp when instr_class_signal = DP and opcode = "1010" and S_bit = '1'
    else cmn when instr_class_signal = DP and opcode = "1011" and S_bit = '1'
    else orr when instr_class_signal = DP and opcode = "1100"
    else mov when instr_class_signal = DP and opcode = "1101"
    else bic when instr_class_signal = DP and opcode = "1110"
    else movn when instr_class_signal = DP and opcode = "1111"
    else ldrsh when instr_class_signal = DT and F_field = "00" and L_bit = '1' and sh = "11"
    else ldrh when instr_class_signal = DT and F_field = "00" and L_bit = '1' and sh = "01"
    else ldrsb when instr_class_signal = DT and F_field = "00" and L_bit = '1' and sh = "10"
    else strh when instr_class_signal = DT and F_field = "00" and L_bit = '0' and sh = "01"
    else ldr when instr_class_signal = DT and F_field ="01" and L_bit = '1' and cond = "1110" and ((P_bit='0' and W_bit = '0') or P_bit = '1') and B_bit = '0'
    else str when instr_class_signal = DT and F_field ="01" and L_bit = '0' and cond = "1110" and ((P_bit='0' and W_bit = '0') or P_bit = '1') and B_bit = '0'
    else ldrb when instr_class_signal = DT and F_field ="01" and L_bit = '1' and cond = "1110" and ((P_bit='0' and W_bit = '0') or P_bit = '1') and B_bit = '1'
    else strb when instr_class_signal = DT and F_field ="01" and L_bit = '0' and cond = "1110" and ((P_bit='0' and W_bit = '0') or P_bit = '1') and B_bit = '1'
    else beq when instr_class_signal = branch and cond = "0000" and opc = "10"
    else bne when instr_class_signal = branch and cond = "0001" and opc = "10"
    else b when instr_class_signal = branch and cond = "1110" and opc = "10"
    else unknown;
end Behavioral;