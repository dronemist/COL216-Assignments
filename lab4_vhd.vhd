library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
  Port (
    clk,reset: in std_logic;
    instruction,data_in  :in std_logic_vector(31 downto 0);
    add_to_program_m,add_to_data_m,data_out: out std_logic_vector(31 downto 0);
    wen: out std_logic
  );
end CPU;

architecture Behavioral of CPU is
signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit, L_bit, S_bit : std_logic;
signal shift_spec : std_logic_vector (7 downto 0);
signal opcode : std_logic_vector(3 downto 0);
signal rn,rd,RotSpec,rm: std_logic_vector(3 downto 0);
signal imm8:std_logic_vector(7 downto 0);
type vector_of_vector is array (0 to 15) of std_logic_vector(31 downto 0);
signal instr_class : instr_class_type;
signal to_be_added:std_logic_vector(31 downto 0);
begin

cond <= instruction(31 downto 28);
F_field <= instruction(27 downto 26);
I_bit <= instruction(25);
L_bit <= instruction(20);
S_bit <= instruction(20);
shift_spec <= instruction (11 downto 4);
opcode <= instruction(24 downto 21);
rn <= instruction(19 downto 16);
rd <= instruction(15 downto 12);
rm <= instruction(3 downto 0);
RotSpec <= instruction(11 downto 8);
imm8 <= instruction(7 downto 0);
to_be_added <= X"000000" & imm8 when I_bit = '1'
                else register_file(to_integer(unsigned(rm)));
with F_field select instr_class <= DP when "00",
               DT when "01",
               branch when "10",
               unknown when others;
	i_decoded <= add when instr_class = DP and opcode = "0100"
        else sub when instr_class = DP and opcode = "0010"
        else mov when instr_class = DP and opcode = "1101"
        else cmp when instr_class = DP and opcode = "1010"
        else ldr when instr_class = DT and L_bit = '1'
        else str when instr_class = DT and L_bit = '0'
        else beq when instr_class = branch and cond = "0000"
        else bne when instr_class = branch and cond = "0001"
        else b when instr_class = branch and cond = "1110"
        else unknown; --idecoded_type

Process(clk)
begin
    if rising_edge(clk) then
        case i_decoded is
            when add =>
                register_file(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(register_file(to_integer(unsigned(rn))))) + std_logic_vector(unsigned(to_be_added));
            when sub =>
                register_file(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(register_file(to_integer(unsigned(rn))))) - std_logic_vector(unsigned(to_be_added));
            when mov =>
                register_file(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(to_be_added));
            when cmp =>

        end case;
    end if;
end process;

--Process()
--begin

--end process;

--Process()
--begin

--end process;

end Behavioral;