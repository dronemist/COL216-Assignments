----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2019 04:03:22 PM
-- Design Name: 
-- Module Name: register_file - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
Port ( 
    clk: in std_logic;
	mode : in mode_type;
    rd_0_addr_inp: in std_logic_vector(3 downto 0);-- rd_1 signifies read port 1
    rd_0_data_out :out std_logic_vector(31 downto 0);
    rd_1_addr_inp: in std_logic_vector(3 downto 0);-- rd_1 signifies read port 1
    rd_1_data_out :out std_logic_vector(31 downto 0);
    rd_2_addr_inp: in std_logic_vector(3 downto 0);
    rd_2_data_out :out std_logic_vector(31 downto 0); 
    wr_1_addr_inp: in std_logic_vector(3 downto 0);
    wr_1_data_inp: in std_logic_vector(31 downto 0);
    wr_1_we : in std_logic;
    pc_data_in: in std_logic_vector(31 downto 0);
    pc_data_out:out std_logic_vector(31 downto 0);
    pc_wea: in std_logic
);
end register_file;

architecture Behavioral of register_file is
type vector_of_vector is array (0 to 15) of std_logic_vector(31 downto 0);
signal r13_svc, r14_svc : std_logic_vector(31 downto 0);
signal register_file: vector_of_vector := (others => (others => '0'));
signal pc: std_logic_vector(31 downto 0) := x"00000000";
begin
rd_2_data_out <= register_file(to_integer(unsigned(rd_2_addr_inp))) when ((mode = user) or ((mode = supervisor) and ((to_integer(unsigned(rd_2_addr_inp)) <= 12) or (to_integer(unsigned(rd_2_addr_inp) = 15)))))
				else r13_svc when ((mode = supervisor) and (to_integer(unsigned(rd_2_addr_inp)) = 13))
				else r14_svc when ((mode = supervisor) and (to_integer(unsigned(rd_2_addr_inp)) = 14));

				
rd_1_data_out <= register_file(to_integer(unsigned(rd_1_addr_inp))) when ((mode = user) or ((mode = supervisor) and ((to_integer(unsigned(rd_1_addr_inp)) <= 12) or (to_integer(unsigned(rd_1_addr_inp) = 15)))))
				else r13_svc when ((mode = supervisor) and (to_integer(unsigned(rd_1_addr_inp)) = 13))
				else r14_svc when ((mode = supervisor) and (to_integer(unsigned(rd_1_addr_inp)) = 14))
				
rd_0_data_out <= register_file(to_integer(unsigned(rd_0_addr_inp)));

process(clk)
begin
   if rising_edge(clk) then
       if (wr_1_we = '1' and not(wr_1_addr_inp = "1111")) then
           register_file(to_integer(unsigned(wr_1_addr_inp))) <= wr_1_data_inp;   
       end if;
       if ((wr_1_we = '1') and (pc_wea = '0') and (wr_1_addr_inp = "1111")) then
           register_file(15) <= wr_1_data_inp;
       elsif pc_wea = '1' then 
           register_file(15) <= pc_data_in;
       end if;
   end if;
end process;
        
        -- register_file(0) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0000";
        -- register_file(1) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0001";
        -- register_file(2) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0010";
        -- register_file(3) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0011";
        -- register_file(4) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0100";
        -- register_file(5) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0101";
        -- register_file(6) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0110";
        -- register_file(7) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "0111";
        -- register_file(8) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1000";
        -- register_file(9) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1001";
        -- register_file(10) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1010";
        -- register_file(11) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1011";
        -- register_file(12) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1100";
        -- register_file(13) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1101";
        -- register_file(14) <= wr_1_data_inp when (wr_1_we = '1') and wr_1_addr_inp = "1110";
        -- register_file(15) <= wr_1_data_inp when (wr_1_we = '1') and (pc_wea = '0') and wr_1_addr_inp = "1111"
                          -- else  pc_data_in when (pc_wea = '1');

pc_data_out <= register_file(15);
--register_file(15) <= pc_data_in when (pc_wea = '1');
end Behavioral;
