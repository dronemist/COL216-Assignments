library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
PACKAGE fun_pkg IS
FUNCTION bit_reverse(s1:std_logic_vector) return std_logic_vector;
END fun_pkg;
package body fun_pkg is 
FUNCTION bit_reverse(s1:std_logic_vector) return std_logic_vector is 
     variable rr : std_logic_vector(s1'high downto s1'low); 
  begin 
    for ii in s1'high downto s1'low loop 
      rr(ii) := s1(s1'high-ii); 
    end loop; 
    return rr; 
  end bit_reverse;
end fun_pkg;   
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
entity shifter_rotator_2 is
	port(
		shifter_input : in std_logic_vector(31 downto 0);
		shift_type : in std_logic_vector(1 downto 0);
		select_bit : in std_logic;
		shifter_output : out std_logic_vector(31 downto 0);
		carry_in : in std_logic;
		carry_out : out std_logic
	);
end entity;

-- 00=LOL 01=LOR 10=AR 11-ROR

architecture shifter_rotator_2_arch of shifter_rotator_2 is 
signal msb : std_logic;
signal last_2_bits : std_logic_vector(1 downto 0);
signal first_2_bits_output : std_logic_vector(1 downto 0);
signal msb_vector : std_logic_vector(1 downto 0);
begin
msb_vector(0) <= msb;
msb_vector(1) <= msb;
first_2_bits_output <= "00" when shift_type = "01" or shift_type = "00"
					else msb_vector when shift_type = "10"
					else last_2_bits when shift_type = "11";
msb <= shifter_input(31);
last_2_bits <= shifter_input(1 downto 0);
shifter_output(31 downto 30) <= first_2_bits_output when select_bit = '1'
							else shifter_input(31 downto 30) when select_bit = '0';
shifter_output(29 downto 0) <= shifter_input(31 downto 2) when select_bit = '1'
							else shifter_input(29 downto 0) when select_bit = '0';
carry_out <= carry_in when select_bit = '0'
			else last_2_bits(1) when select_bit = '1';

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
entity shifter_rotator_1 is
	port(
		shifter_input : in std_logic_vector(31 downto 0);
		shift_type : in std_logic_vector(1 downto 0);
		select_bit : in std_logic;
		shifter_output : out std_logic_vector(31 downto 0);
		carry_in : in std_logic;
		carry_out : out std_logic
	);
end entity;

-- 00=LOL 01=LOR 10=AR 11-ROR

architecture shifter_rotator_1_arch of shifter_rotator_1 is 
signal msb : std_logic;
signal last_bit : std_logic;
signal first_bit_output : std_logic;
begin
--msb_vector(0) <= msb;
--msb_vector(1) <= msb;
first_bit_output <= '0' when shift_type = "01" or shift_type = "00"
				else msb when shift_type = "10"
				else last_bit when shift_type = "11";
msb <= shifter_input(31);
last_bit <= shifter_input(0);
shifter_output(31) <= first_bit_output when select_bit = '1'
						else shifter_input(31) when select_bit = '0';
shifter_output(30 downto 0) <= shifter_input(31 downto 1) when select_bit = '1'
							else shifter_input(30 downto 0) when select_bit = '0';
carry_out <= carry_in when select_bit = '0'
			else last_bit when select_bit = '1';

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
entity shifter_rotator_4 is
	port(
		shifter_input : in std_logic_vector(31 downto 0);
		shift_type : in std_logic_vector(1 downto 0);
		select_bit : in std_logic;
		shifter_output : out std_logic_vector(31 downto 0);
		carry_in : in std_logic;
		carry_out : out std_logic
	);
end entity;

-- 00=LOL 01=LOR 10=AR 11-ROR

architecture shifter_rotator_4_arch of shifter_rotator_4 is 
signal msb : std_logic;
signal last_4_bits : std_logic_vector(3 downto 0);
signal first_4_bits_output : std_logic_vector(3 downto 0);
signal msb_vector : std_logic_vector(3 downto 0);
begin
msb_vector(0) <= msb;
msb_vector(1) <= msb;
msb_vector(2) <= msb;
msb_vector(3) <= msb;
first_4_bits_output <= "0000" when shift_type = "01" or shift_type = "00"
					else msb_vector when shift_type = "10"
					else last_4_bits when shift_type = "11";
msb <= shifter_input(31);
last_4_bits <= shifter_input(3 downto 0);
shifter_output(31 downto 28) <= first_4_bits_output when select_bit = '1'
							else shifter_input(31 downto 28) when select_bit = '0';
shifter_output(27 downto 0) <= shifter_input(31 downto 4) when select_bit = '1'
							else shifter_input(27 downto 0) when select_bit = '0';
carry_out <= carry_in when select_bit = '0'
			else last_4_bits(3) when select_bit = '1';

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
entity shifter_rotator_8 is
	port(
		shifter_input : in std_logic_vector(31 downto 0);
		shift_type : in std_logic_vector(1 downto 0);
		select_bit : in std_logic;
		shifter_output : out std_logic_vector(31 downto 0);
		carry_in : in std_logic;
		carry_out : out std_logic
	);
end entity;

-- 00=LOL 01=LOR 10=AR 11-ROR

architecture shifter_rotator_8_arch of shifter_rotator_8 is 
signal msb : std_logic;
signal last_8_bits : std_logic_vector(7 downto 0);
signal first_8_bits_output : std_logic_vector(7 downto 0);
signal msb_vector : std_logic_vector(7 downto 0);
begin
msb_vector(0) <= msb;
msb_vector(1) <= msb;
msb_vector(2) <= msb;
msb_vector(3) <= msb;
msb_vector(4) <= msb;
msb_vector(5) <= msb;
msb_vector(6) <= msb;
msb_vector(7) <= msb;
first_8_bits_output <= "00000000" when shift_type = "01" or shift_type = "00"
					else msb_vector when shift_type = "10"
					else last_8_bits when shift_type = "11";
msb <= shifter_input(31);
last_8_bits <= shifter_input(7 downto 0);
shifter_output(31 downto 24) <= first_8_bits_output when select_bit = '1'
							else shifter_input(31 downto 24) when select_bit = '0';
shifter_output(23 downto 0) <= shifter_input(31 downto 8) when select_bit = '1'
							else shifter_input(23 downto 0) when select_bit = '0';
carry_out <= carry_in when select_bit = '0'
			else last_8_bits(7) when select_bit = '1';

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
entity shifter_rotator_16 is
	port(
		shifter_input : in std_logic_vector(31 downto 0);
		shift_type : in std_logic_vector(1 downto 0);
		select_bit : in std_logic;
		shifter_output : out std_logic_vector(31 downto 0);
		carry_in : in std_logic;
		carry_out : out std_logic
	);
end entity;

-- 00=LOL 01=LOR 10=AR 11-ROR

architecture shifter_rotator_16_arch of shifter_rotator_16 is 
signal msb : std_logic;
signal last_16_bits : std_logic_vector(15 downto 0);
signal first_16_bits_output : std_logic_vector(15 downto 0);
signal msb_vector : std_logic_vector(15 downto 0);
begin
msb_vector(0) <= msb;
msb_vector(1) <= msb;
msb_vector(2) <= msb;
msb_vector(3) <= msb;
msb_vector(4) <= msb;
msb_vector(5) <= msb;
msb_vector(6) <= msb;
msb_vector(7) <= msb;
msb_vector(8) <= msb;
msb_vector(9) <= msb;
msb_vector(10) <= msb;
msb_vector(11) <= msb;
msb_vector(12) <= msb;
msb_vector(13) <= msb;
msb_vector(14) <= msb;
msb_vector(15) <= msb;

first_16_bits_output <= "0000000000000000" when shift_type = "01" or shift_type = "00"
					else msb_vector when shift_type = "10"
					else last_16_bits when shift_type = "11";
msb <= shifter_input(31);
last_16_bits <= shifter_input(15 downto 0);
shifter_output(31 downto 16) <= first_16_bits_output when select_bit = '1'
							else shifter_input(31 downto 16) when select_bit = '0';
shifter_output(15 downto 0) <= shifter_input(31 downto 16) when select_bit = '1'
							else shifter_input(15 downto 0) when select_bit = '0';
carry_out <= carry_in when select_bit = '0'
			else last_16_bits(15) when select_bit = '1';

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
use work.common_type.all;
use work.fun_pkg.all;
entity final_shifter_rotator is 
	port(
		shifter_input : in std_logic_vector(31 downto 0);
		shift_type : in std_logic_vector(1 downto 0);
		select_bits : in std_logic_vector(4 downto 0);
		shifter_output : out std_logic_vector(31 downto 0);
		carry_in : in std_logic;
		carry_out : out std_logic
	);
end entity;

architecture behavorial of final_shifter_rotator is 
signal shift_1_out, shift_2_out, shift_4_out, shift_8_out: std_logic_vector(31 downto 0);
signal shift_1_carry_out, shift_2_carry_out, shift_4_carry_out, shift_8_carry_out : std_logic;
signal processed_input_signal, processed_output_signal: std_logic_vector(31 downto 0);

begin
	processed_input_signal <= bit_reverse(shifter_input) when shift_type = "00"
								else shifter_input;
	shifter_output <=  bit_reverse(processed_output_signal) when shift_type = "00"
								else shifter_input;
	shift_rot:entity work.shifter_rotator_1(shifter_rotator_1_arch) PORT MAP(processed_input_signal, shift_type, select_bits(4), shift_1_out, carry_in, shift_1_carry_out);
	shift_rot1:entity work.shifter_rotator_2(shifter_rotator_2_arch) PORT MAP(shift_1_out, shift_type, select_bits(3), shift_2_out, shift_1_carry_out, shift_2_carry_out);
	shift_rot2:entity work.shifter_rotator_4(shifter_rotator_4_arch) PORT MAP(shift_2_out, shift_type, select_bits(2), shift_4_out, shift_2_carry_out, shift_4_carry_out);
	shift_rot3:entity work.shifter_rotator_8(shifter_rotator_8_arch) PORT MAP(shift_4_out, shift_type, select_bits(1), shift_8_out, shift_4_carry_out, shift_8_carry_out);
	shift_rot4:entity work.shifter_rotator_16(shifter_rotator_16_arch) PORT MAP(shift_8_out, shift_type, select_bits(0), processed_output_signal, shift_8_carry_out, carry_out);
	

end architecture;

