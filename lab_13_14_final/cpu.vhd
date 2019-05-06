library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;
package common_type is
type instr_class_type is (DP, DT, branch,halt, DP_mull, swi,psr, unknown);
type i_decoded_type is (add,sub,cmp,mov,and_instr,eor,orr,bic,adc,sbc,rsb,rsc,mul,mla,mull,smull,smlal,umull,umlal,cmn,tst,teq,movn,ldr,str,ldrb,strb,ldrsb,ldrh,strh,ldrsh,beq,bne,b,swi,unknown,msr,mrs);
type execution_state_type is (initial,onestep,oneinstr,cont,done);
type control_state_type is (fetch,decode,decode_shift,arith,mult,alu_mult,res2RF_1,res2RF_2,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF,exception_handler,skip,res2RF_psr,arith_psr);
type alu_op_type is(op_and,op_xor,sub,rsb,add,adc,sbc,rsc,orr,mov,bic,mvn,mul);
type mode_type is (user, supervisor);
type display_mode_type is(single,multiple,read,none);
type exception_type is (Reset_exception, IRQ_exception, Undefined, SWI, None); 
end common_type; 

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

entity CPU is
  Port (
    clk,exception_reset,step,go,instr,reset: in std_logic;
    program_select: in std_logic_vector(2 downto 0);
    register_select: in std_logic_vector(3 downto 0);
    add_to_program_m,add_to_data_m,data_out, data_in, RF_data_out, instruction_disp: out std_logic_vector(31 downto 0);
    memory_wea : out std_logic;
    exception_output : out exception_type;
    irq_output, irq_ack_output : out std_logic;
    control_state_output : out control_state_type;
    mode_output : out mode_type;
    is_valid_output : out std_logic;
	keypad_is_key_pressed : in std_logic;
	keypad_key_decoded : in std_logic_vector(3 downto 0)
  );
end CPU;

architecture cpu_arch of CPU is
signal IR,DR,A,B_reg,d_reg, res,next_PC,instruction,alu_op_1,alu_op_2,alu_result :std_logic_vector(31 downto 0);
signal PC : std_logic_vector(31 downto 0) := x"00000000";
signal alu_op_to_be_performed : alu_op_type;
signal alu_flag_wea,alu_carry,alu_flag_output: std_logic;
signal control_state: control_state_type;
signal i_decoded: i_decoded_type;
signal execution_state: execution_state_type;
signal RF_rd_0_addr_inp: std_logic_vector(3 downto 0);
signal RF_rd_0_data_out : std_logic_vector(31 downto 0);
signal RF_rd_1_addr_inp: std_logic_vector(3 downto 0);-- rd_1 signifies read port 1
signal RF_rd_1_data_out : std_logic_vector(31 downto 0);
signal RF_rd_2_addr_inp: std_logic_vector(3 downto 0);
signal RF_rd_2_data_out : std_logic_vector(31 downto 0); 
signal RF_wr_1_addr_inp: std_logic_vector(3 downto 0);
signal RF_wr_1_data_inp: std_logic_vector(31 downto 0);
signal RF_wr_1_we : std_logic;
signal RF_pc_data_in: std_logic_vector(31 downto 0);
signal RF_pc_wea,I_bit,U_bit, S_bit, predicate_bit,link_bit: std_logic;
signal instr_class : instr_class_type;
signal ld_bit,green_flag,data_mem_0_we,data_mem_1_we,data_mem_2_we,data_mem_3_we,p_bit,w_bit : std_logic;
signal red_flag : std_logic;
signal imm8:std_logic_vector(7 downto 0);
signal imm12:std_logic_vector(11 downto 0);
signal data_mem_0_data_in,data_mem_0_data_out,data_mem_1_data_in,data_mem_1_data_out,data_mem_2_data_in,data_mem_2_data_out,data_mem_3_data_in,data_mem_3_data_out: std_logic_vector(7 downto 0);  
-- 0 denotes the least significant 8 bits of data_memory
signal data_mem_data_out, data_mem_data_in : std_logic_vector(31 downto 0);
signal data_mem_add_to_data_m : std_logic_vector(31 downto 0);
signal shifter_input : std_logic_vector(31 downto 0);
signal shift_type : std_logic_vector(1 downto 0);
signal type_of_shift : std_logic;
signal shift_amount : std_logic_vector(4 downto 0);
signal shifter_output : std_logic_vector(31 downto 0);
signal alu_carry_in : std_logic;
signal shifter_carry_out, shifter_carry_out_reg : std_logic;
signal z_flag, n_flag, c_flag, v_flag : std_logic;
signal imm7_4, imm3_0, rot_spec : std_logic_vector(3 downto 0);
signal mult_output, mult_output_reg : std_logic_vector(63 downto 0);
signal mult_inp_1, mult_inp_2 : std_logic_vector(31 downto 0);
signal signed_mult_and_add : std_logic; 
signal adder_op_2, mla_result, mla_result_reg : std_logic_vector(63 downto 0);
signal upper_32_mla_inp_bits, lower_32_mla_inp_bits,upper_32_mla_out_bits, lower_32_mla_out_bits : std_logic_vector(31 downto 0);
signal mode : mode_type;
signal usr_mode_encoding, supervisor_mode_encoding : std_logic_vector(4 downto 0);
signal cpsr : std_logic_vector(31 downto 0) := x"000000" & "10010011";
signal spsr_svc : std_logic_vector(31 downto 0);  
signal reset_addr, undef_addr, swi_addr, irq_addr : std_logic_vector(31 downto 0);
signal reset_on_prev_state,is_valid: std_logic;
signal exception, exception_signal : exception_type;
signal m_field : std_logic_vector(4 downto 0);
signal irq, irq_ack : std_logic;
signal wait_for_input : std_logic := '1'; -- 1 if input key has not been pressed

component data_memory
        Port (
            a: in std_logic_vector(9 downto 0);
            d: in std_logic_vector(7 downto 0);
            clk: in std_logic;
            we: in std_logic;
            spo: out std_logic_vector(7 downto 0)
        );
end component;
component program_memory
        Port(
            a: in std_logic_vector(9 downto 0);
            spo: out std_logic_vector(31 downto 0)
        );
end component;
component control_state_FSM
        Port (
            instr_class : in instr_class_type;
			is_valid: in std_logic;
			reset,ld_bit,green_flag,clk,irq :in std_logic;
			exception : in exception_type;
			red_flag : out std_logic;
			predicate_bit:in std_logic;
			control_state: out control_state_type;
			wait_for_input: in std_logic
        );
end component;
component execution_state_FSM
        Port (
            step,instr,go,reset,clk:in std_logic;
            control_state:in control_state_type;
            red_flag : in std_logic;
            execution_state: out execution_state_type;
            green_flag: out std_logic
        );
end component;
component ALU_and_flags
        Port (
			 clk : in std_logic;
             op_1: in std_logic_vector(31 downto 0);
             op_2: in std_logic_vector(31 downto 0);
             op_3: in std_logic_vector(63 downto 0);
             carry,s_bit: in std_logic;
             carry_from_shifter : in std_logic;
             op_to_be_performed :in alu_op_type;
             shift_amount : in std_logic_vector(4 downto 0);
             wea : in std_logic ;
             z_flag_output,n_flag_output,v_flag_output,c_flag_output: out std_logic;
             result:out std_logic_vector(31 downto 0)
        );
end component;
component register_file
        Port ( 
            clk: in std_logic;
			mode: in mode_type;
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
end component;
component instruction_decoder
    Port ( 
      instruction : in std_logic_vector(31 downto 0);
      instr_class : out instr_class_type;
      i_decoded : out i_decoded_type
    );
end component;
component final_shifter_rotator
    Port (
        shifter_input : in std_logic_vector(31 downto 0);
        shift_type : in std_logic_vector(1 downto 0);
        select_bits : in std_logic_vector(4 downto 0);
        shifter_output : out std_logic_vector(31 downto 0);
        carry_in : in std_logic;
        carry_out : out std_logic
    );
end component;
component multiplier is
Port (
       op_1: in std_logic_vector(31 downto 0);
       op_2: in std_logic_vector(31 downto 0);
       is_signed: in std_logic;
       mul_result: out std_logic_vector(63 downto 0)
 );
end component;
component adder_64_bit is
Port (
       op_1: in std_logic_vector(63 downto 0);
       op_2: in std_logic_vector(63 downto 0);
       is_signed: in std_logic;
       add_result: out std_logic_vector(63 downto 0)
 );
end component;
component predicate_calculator is
  Port (
  z_flag,n_flag,c_flag,v_flag: in std_logic;
  ins: in std_logic_vector(3 downto 0);
  predicate: out std_logic
   );
end component;
component irq_generator is
Port ( 
    clk, irq_ack,reset : in std_logic; 
    irq_output : out std_logic
);
end component;
begin
irq_generator_instance: irq_generator port map(
    clk => clk,
    irq_ack => irq_ack,
    reset => reset,
    irq_output => irq
);

predicate_instance: predicate_calculator port map(
    z_flag => CPSR(30),
    n_flag => CPSR(31),
    c_flag => CPSR(29),
    v_flag => CPSR(28),
    ins => IR(31 downto 28),
  predicate => predicate_bit
);
data_memory_instance_0: data_memory port map( 
            a => data_mem_add_to_data_m(9 downto 0),
            d => data_mem_0_data_out,
            clk => clk,
            we => data_mem_0_we,
            spo => data_mem_0_data_in
        );
		
data_memory_instance_1: data_memory port map( 
            a => data_mem_add_to_data_m(9 downto 0),
            d => data_mem_1_data_out,
            clk => clk,
            we => data_mem_1_we,
            spo => data_mem_1_data_in
        );

data_memory_instance_2: data_memory port map( 
            a => data_mem_add_to_data_m(9 downto 0),
            d => data_mem_2_data_out,
            clk => clk,
            we => data_mem_2_we,
            spo => data_mem_2_data_in
        );
		
data_memory_instance_3: data_memory port map( 
            a => data_mem_add_to_data_m(9 downto 0),
            d => data_mem_3_data_out,
            clk => clk,
            we => data_mem_3_we,
            spo => data_mem_3_data_in
        );
		
program_memory_instance: program_memory port map(
                           a => PC(11 downto 2),
                           spo=> instruction
                       );
ALU_instance: ALU_and_flags port map(
						clk => clk,
                        op_1 => alu_op_1,
                        op_2 => alu_op_2,
                        op_3 => mla_result_reg,
                        op_to_be_performed => alu_op_to_be_performed,
                        carry => alu_carry, 
                        s_bit => s_bit,
                        carry_from_shifter => shifter_carry_out_reg,
                        shift_amount => shift_amount,
                        wea => alu_flag_wea,
                        z_flag_output => z_flag,
                        n_flag_output => n_flag,
                        c_flag_output => c_flag,
                        v_flag_output => V_flag,                        
                        result => alu_result
                       );   
RF_instance: register_file port map(
                                   clk => clk,
								   mode => mode,
                                   rd_0_addr_inp => RF_rd_0_addr_inp,-- rd_1 signifies read port 1
                                   rd_0_data_out => RF_rd_0_data_out,
                                   rd_1_addr_inp => RF_rd_1_addr_inp,-- rd_1 signifies read port 1
                                   rd_1_data_out => RF_rd_1_data_out,
                                   rd_2_addr_inp => RF_rd_2_addr_inp,
                                   rd_2_data_out => RF_rd_2_data_out, 
                                   wr_1_addr_inp => RF_wr_1_addr_inp,
                                   wr_1_data_inp => RF_wr_1_data_inp,
                                   wr_1_we => RF_wr_1_we, 
                                   pc_data_in => RF_pc_data_in,
                                   pc_data_out => pc,
                                   pc_wea => RF_pc_wea
                                             );   
control_state_instance: control_state_FSM port map(
            is_valid => is_valid,
            instr_class => instr_class,
            reset => reset,
            irq => irq,
            ld_bit => ld_bit,
            green_flag => green_flag,
            clk => clk,
            red_flag => red_flag,
            predicate_bit => predicate_bit,
            control_state => control_state,
			exception => exception,
			wait_for_input => wait_for_input
     );
execution_state_instance: execution_state_FSM port map(
            step => step,
            instr => instr,
            go => go,
            reset => reset,
            clk => clk,
            control_state => control_state,
            red_flag => red_flag,
            green_flag => green_flag,
            execution_state => execution_state
);     
instruction_decoder_instance: instruction_decoder port map(
            instruction => IR,
            instr_class => instr_class,
            i_decoded => i_decoded
     );
shifter_rotator_instance: final_shifter_rotator port map(
        shifter_input => shifter_input,
		shift_type => shift_type,
		select_bits => shift_amount,
		shifter_output => shifter_output,
		carry_in => '0', --doubtful
		carry_out => shifter_carry_out
);
multiplier_instance: multiplier port map(
        op_1 => mult_inp_1,
        op_2 => mult_inp_2,
        is_signed => signed_mult_and_add,
        mul_result => mult_output
);
adder_64_bit_instance: adder_64_bit port map(
                op_1 => mult_output_reg,
                op_2 => adder_op_2,
                is_signed => signed_mult_and_add,
                add_result => mla_result
);
--wr_addr_inp <="000" & predicate_bit;
mode_output <= mode;
is_valid_output <= is_valid;
irq_output <= irq;
irq_ack_output <= irq_ack;
exception_output <= exception;
control_state_output <= control_state;
rot_spec <= IR(11 downto 8);
RF_data_out <= RF_rd_0_data_out;
RF_rd_0_addr_inp <= register_select;
type_of_shift <= IR(4);-- 0 when constant shift 1 when register specified shift      
--state <= "00";     
add_to_data_m <= data_mem_add_to_data_m;
data_mem_data_in <= data_mem_3_data_in & data_mem_2_data_in & data_mem_1_data_in & data_mem_0_data_in;
data_out <= data_mem_3_data_out & data_mem_2_data_out & data_mem_1_data_out & data_mem_0_data_out;
data_in <= data_mem_data_in;
memory_wea <= data_mem_0_we or data_mem_1_we or data_mem_2_we or data_mem_3_we; 
--data_out <= data_mem_data_out;
add_to_program_m <= PC;                       
imm8 <= IR(7 downto 0);
imm12 <= IR(11 downto 0);
imm7_4 <= IR(11 downto 8);
imm3_0 <= IR(3 downto 0); 
ld_bit <= IR(20);
I_bit <= IR(25);
U_bit <= IR(23);
S_bit <= IR(20);
p_bit <= IR(24);
w_bit <= IR(21);
link_bit <= IR(24);
instruction_disp <= IR;
is_valid <= '1' when mode = supervisor or (mode = user and ((alu_result > X"000000FF" and p_bit = '1') or (A > X"000000FF" and p_bit = '0')))
           else '0' when (mode = user and ((alu_result < X"000000FF" and p_bit = '1') or (A < X"000000FF" and p_bit = '0')));
--IS_VALID <= '1';
--PC <= alu_result & "00" when control_state = fetch;
RF_rd_1_addr_inp <= IR(11 downto 8) when control_state = decode and instr_class = DP_mull                    
                    else IR(19 downto 16) when (control_state = decode or (control_state = mult and instr_class = DP_mull));
RF_rd_2_addr_inp <= IR(3 downto 0) when control_state = decode
                 else IR(15 downto 12) when (control_state = addr or (control_state = mult and instr_class = DP_mull))
                 else IR(11 downto 8) when control_state = decode_shift and type_of_shift = '1';
--alu_op_to_be_performed <= '0' when (((i_decoded = add) and (control_state = arith)) or (control_state = fetch) or (control_state = addr and U_bit = '1') or (control_state = brn))
--                        else '1' when (((i_decoded = sub) and (control_state = arith)) or (control_state = addr and U_bit = '0') or (i_decoded = cmp and control_state = arith));                         

alu_op_to_be_performed <= op_and when (((i_decoded = and_instr) or (i_decoded = tst)) and (control_state = arith))
                       else op_xor when (((i_decoded = teq) or (i_decoded = eor)) and (control_state = arith))
                       else sub when ((((i_decoded = sub) or (i_decoded = cmp)) and (control_state = arith)) or (control_state = addr and U_bit = '0') or (i_decoded = cmp and control_state = arith))
                       else rsb when ((i_decoded = rsb) and (control_state = arith) )
                       else add when ((((i_decoded = add) or (i_decoded = cmn)) and (control_state = arith)) or (control_state = fetch) or (control_state = addr and U_bit = '1') or (control_state = brn))
                       else adc when (((i_decoded = adc) or (i_decoded = b)) and (control_state = arith) )
                       else sbc when (((i_decoded = sbc)) and (control_state = arith) )
                       else rsc when (((i_decoded = rsc)) and (control_state = arith) )
                       else orr when (((i_decoded = orr)) and (control_state = arith) )
                       else mov when (((i_decoded = mov)) and (control_state = arith) )
                       else bic when (((i_decoded = bic)) and (control_state = arith) )
                       else mvn when (((i_decoded = movn)) and (control_state = arith) )
                       else mul when ((instr_class = DP_mull) and (control_state = res2RF_1));

alu_op_1 <= x"00000" & "00" & pc(11 downto 2) when ((control_state = fetch) or (control_state = brn))
          else A when ((control_state = arith) or (control_state = addr))
          else x"00000000";

alu_op_2 <=  x"00000000" when (control_state = fetch)   --rotSpec assumed as  0000
            else D_reg when ((control_state = arith) or (control_state = addr and (I_bit = '1')) or (control_state = addr and IR(22) = '0' and (i_decoded = ldrsh or i_decoded = ldrh or i_decoded = ldrsb or i_decoded = strh)))
            else x"000000" & imm7_4 & imm3_0 when (control_state = addr and IR(22) = '1' and (i_decoded = ldrsh or i_decoded = ldrh or i_decoded = ldrsb or i_decoded = strh))
            else "00000000000000000000" & imm12 when (control_state = addr and (I_bit = '0'))
            else std_logic_vector(to_signed((to_integer(signed(IR(23 downto 0)))),32)) when (control_state = brn)
            else x"00000000";
            
alu_carry <= '1' when ((control_state = fetch) or (control_state = brn))
            else '0';
alu_flag_wea <= '1' when control_state = arith OR control_state = res2RF_1
                            else '0';
data_mem_add_to_data_m <= ( res(31 downto 2) & "00" ) when ((control_state = mem_wr) or (control_state = mem_rd)) and p_bit = '1'
                          else ( A(31 downto 2) & "00" ) when ((control_state = mem_wr) or (control_state = mem_rd)) and p_bit = '0';

shifter_input <= X"000000" & imm8 when ((control_state = decode_shift) and (I_bit = '1') and instr_class = DP)

                else B_reg when (control_state = decode_shift);


shift_amount <= (rot_spec & '0') when ((control_state = decode_shift) and (I_bit = '1') and instr_class = DP)
            else "00000" when ((i_decoded = ldrsh or i_decoded = ldrh or i_decoded = ldrsb or i_decoded = strh) and control_state = decode_shift)
            else (RF_rd_2_data_out(4 downto 0)) when type_of_shift = '1' and control_state = decode_shift
            else IR(11 downto 7) when type_of_shift = '0' and control_state = decode_shift
            else "00000";

shift_type <= "11" when ((control_state = decode_shift) and (I_bit = '1') and instr_class = DP)
            else IR(6 downto 5) when control_state = decode_shift;

mult_inp_1 <= A;
mult_inp_2 <= B_reg;
signed_mult_and_add <= U_bit when (not (i_decoded = mul) and not(i_decoded = mla))
                        else '1';
adder_op_2 <= upper_32_mla_inp_bits & lower_32_mla_inp_bits when i_decoded = smlal or i_decoded = mla or i_decoded = umlal
              else x"0000000000000000";
upper_32_mla_out_bits <= mla_result(63 downto 32);
lower_32_mla_out_bits <= mla_result(31 downto 0);
reset_addr <= x"00000000";
undef_addr <= x"00000004";
swi_addr <= x"00000008";
irq_addr <= x"00000018";
usr_mode_encoding <= "10000";
supervisor_mode_encoding <= "10011"; 
m_field <= cpsr(4 downto 0);
mode <= user when m_field = usr_mode_encoding
        else supervisor when m_field = supervisor_mode_encoding;
exception <= Reset_exception when exception_reset = '1'
			else SWI when i_decoded = swi and control_state = decode
			else Undefined when i_decoded = unknown and control_state = decode
			else IRQ_exception when control_state = skip and (irq = '1') and (cpsr(7)='0')  --dont know its condition
			else None;
			
irq_ack <= '1' when (control_state = exception_handler and exception_signal = irq_exception)
            else '0';
wait_for_input <= not(keypad_is_key_pressed) when (control_state = mem_rd) and (data_mem_add_to_data_m = x"0000000" & "1100")
					else '0';
	
-- cpsr(27 downto 8) <= x"00000" & "0";
-- cpsr(6 downto 5) <= "00";
-- spsr(27 downto 8) <= x"00000" & "0";
-- spsr(6 downto 5) <= "00";

--IR <= instruction when (control_state = fetch);
-- final process
process(clk, reset, green_flag)
begin
    if reset = '1' then
        RF_pc_data_in <= "0000000000000000000000" &  program_select(2 downto 0)  & "0000000";
        RF_pc_wea <= '1';
    else
        if rising_edge(clk) then
        if green_flag = '1' then
            exception_signal <= exception;
            if RF_pc_wea = '1' then
                RF_pc_wea <= '0';
            end if;
            if RF_wr_1_we = '1' then
                    RF_wr_1_we <= '0';
            end if;
            if data_mem_0_we = '1' then
                data_mem_0_we <= '0';
            end if;
            if data_mem_1_we = '1' then
                data_mem_1_we <= '0';
            end if;
            if data_mem_2_we = '1' then
                data_mem_2_we <= '0';
            end if;
            if data_mem_3_we = '1' then
                data_mem_3_we <= '0';
            end if;        
            case control_state is
                when fetch => 
                    --alu_op_1 <= x"000000" & "0" & pc(9 downto 2);
                    --alu_op_2 <= x"00000000";
                    --alu_carry <= '1';
                    RF_pc_wea <= '1';
                    RF_pc_data_in <= alu_result(29 downto 0) & "00";
                    IR <= instruction;
                    
                when decode =>
                    if i_decoded = mov then
                                A <= X"00000000";
                               else 
                                A <= RF_rd_1_data_out;
                               end if;                      
                    B_reg <= RF_rd_2_data_out;
                when mult =>
                    mult_output_reg <= mult_output;
                    if i_decoded = smull or i_decoded = smlal or i_decoded = umull or i_decoded = umlal then
                        upper_32_mla_inp_bits <= RF_rd_1_data_out; 
                    else 
                        if RF_rd_2_data_out(31) = '0' then upper_32_mla_inp_bits <= x"00000000" ;
                        else upper_32_mla_inp_bits <= x"ffffffff";
                        end if;
                    end if;
                    lower_32_mla_inp_bits <= RF_rd_2_data_out;
                when alu_mult =>
                    mla_result_reg <= mla_result;
                when res2RF_1 =>
                    RF_wr_1_addr_inp <= IR(19 downto 16);
                    if i_decoded = smull or i_decoded = smlal or i_decoded = umull or i_decoded = umlal then 
                        RF_wr_1_data_inp <= mla_result(63 downto 32); 
                    else 
                        RF_wr_1_data_inp <= mla_result(31 downto 0);
                    end if;
                    RF_wr_1_we <= '1';
                when res2RF_2 =>
                    RF_wr_1_addr_inp <= IR(15 downto 12);
                    if i_decoded = smull or i_decoded = smlal or i_decoded = umull or i_decoded = umlal then 
                        RF_wr_1_data_inp <= mla_result(31 downto 0);
                        RF_wr_1_we <= '1';                 
                    end if;
                when decode_shift =>
                    d_reg <= shifter_output; 
                    shifter_carry_out_reg <= shifter_carry_out;
                when arith =>
                    --alu_op_1 <= A;
                    --if I_bit = '1' then
                    --    alu_op_2 <= X"000000" & imm8;
                    --else
                    --    alu_op_2 <= B_reg;
                    --end if;    
                    res <= alu_result;
                when res2RF =>
                    RF_wr_1_addr_inp <= IR(15 downto 12);
                    RF_wr_1_data_inp <= res;
                    if not(i_decoded = cmp or i_decoded = cmn or i_decoded = tst or i_decoded = teq) then 
                        RF_wr_1_we <= '1';    
                    end if;
                    if i_decoded = mov and s_bit='1' and mode = supervisor and IR(15 downto 12) = "1111" then
                        CPSR <= spsr_svc;
                    end if ;
                when addr =>
                    --alu_op_1 <= A;
                    --alu_op_2 <= "00000000000000000000" & imm12;

                    res <= alu_result;
                    B_reg <= RF_rd_2_data_out; 
                when mem_wr =>
                    --data_mem_add_to_data_m <= res;
    --                data_mem_data_out <= B_reg;   
                    if(w_bit='1' or(p_bit='0' and w_bit='0')) then
                        RF_wr_1_addr_inp <= IR(19 downto 16);
                        RF_wr_1_data_inp <= res;
                        RF_wr_1_we <= '1';
                    end if;
                    case i_decoded is
                        when strb => 
                         data_mem_0_data_out <= B_reg(7 downto 0);
                         data_mem_1_data_out <= B_reg(7 downto 0);
                         data_mem_2_data_out <= B_reg(7 downto 0);
                         data_mem_3_data_out <= B_reg(7 downto 0);
                         if p_bit = '1' then
                             case res(1 downto 0) is
                                 when "00" => data_mem_3_we <= '1';
                                 when "01" => data_mem_2_we <= '1';
                                 when "10" => data_mem_1_we <= '1';
                                 when "11" => data_mem_0_we <= '1';
                                 when others =>
                             end case;
                         else
                             case A(1 downto 0) is
                                 when "00" => data_mem_3_we <= '1';
                                 when "01" => data_mem_2_we <= '1';
                                 when "10" => data_mem_1_we <= '1';
                                 when "11" => data_mem_0_we <= '1';
                                 when others =>
                            end case;                        
                         end if;
                         
                         when strh => 
                          data_mem_0_data_out <= B_reg(7 downto 0);
                          data_mem_1_data_out <= B_reg(15 downto 8);
                          data_mem_2_data_out <= B_reg(7 downto 0);
                          data_mem_3_data_out <= B_reg(15 downto 8);
                          if p_bit = '1' then 
                              case res(1) is
                               when '1' => data_mem_0_we <= '1'; data_mem_1_we <= '1';
                               when '0' => data_mem_2_we <= '1'; data_mem_3_we <= '1';
                               when others =>
                              end case;
                          else
                              case A(1) is
                               when '1' => data_mem_0_we <= '1'; data_mem_1_we <= '1';
                               when '0' => data_mem_2_we <= '1'; data_mem_3_we <= '1';
                               when others =>
                              end case;                      
                          end if;
                          
                         when str =>
                          data_mem_0_data_out <= B_reg(7 downto 0);
                          data_mem_1_data_out <= B_reg(15 downto 8);
                          data_mem_2_data_out <= B_reg(23 downto 16);
                          data_mem_3_data_out <= B_reg(31 downto 24);
                          data_mem_0_we <= '1';
                          data_mem_1_we <= '1';
                          data_mem_2_we <= '1';
                          data_mem_3_we <= '1';
                         
                         when others => 
                    end case;
    --                data_mem_we <= '1';
                when mem_rd =>
                    --data_mem_add_to_data_m <= res;
                    if(w_bit='1' or(p_bit='0' and w_bit='0')) then
                        RF_wr_1_addr_inp <= IR(19 downto 16);
                        RF_wr_1_data_inp <= res;
                        RF_wr_1_we <= '1';
                    end if;
					if wait_for_input ='0' then
						DR <= x"0000000" & keypad_key_decoded;
                    elsif i_decoded = ldr then
                        DR <= data_mem_data_in ;
                    elsif i_decoded = ldrb then
                        if p_bit = '1' then
                            case res(1 downto 0) is
                                when "00" => DR <= x"000000" & data_mem_3_data_in;
                                when "01" => DR <= x"000000" & data_mem_2_data_in;
                                when "10" => DR <= x"000000" & data_mem_1_data_in;
                                when "11" => DR <= x"000000" & data_mem_0_data_in;
                                when others =>
                            end case;
                        else
                            case A(1 downto 0) is
                                when "00" => DR <= x"000000" & data_mem_3_data_in;
                                when "01" => DR <= x"000000" & data_mem_2_data_in;
                                when "10" => DR <= x"000000" & data_mem_1_data_in;
                                when "11" => DR <= x"000000" & data_mem_0_data_in;
                                when others =>
                            end case;                    
                        end if;
                     elsif i_decoded = ldrh then
                        if p_bit = '1' then
                            case res(1) is
                             when '1' => DR <= x"0000" & data_mem_1_data_in & data_mem_0_data_in;
                             when '0' => DR <= x"0000" & data_mem_3_data_in & data_mem_2_data_in;
                             when others =>
                            end case;      
                        else
                            case A(1) is
                             when '1' => DR <= x"0000" & data_mem_1_data_in & data_mem_0_data_in;
                             when '0' => DR <= x"0000" & data_mem_3_data_in & data_mem_2_data_in;
                             when others =>
                            end case;                    
                        end if;               
                     elsif i_decoded = ldrsb then 
                        if p_bit = '1' then
                            case res(1 downto 0) is
                                when "11" => if data_mem_0_data_in(7) = '0' then DR <= x"000000" & data_mem_0_data_in; else DR <= x"ffffff" & data_mem_0_data_in; end if;
                                when "10" => if data_mem_1_data_in(7) = '0' then DR <= x"000000" & data_mem_1_data_in; else DR <= x"ffffff" & data_mem_1_data_in; end if;
                                when "01" => if data_mem_2_data_in(7) = '0' then DR <= x"000000" & data_mem_2_data_in; else DR <= x"ffffff" & data_mem_2_data_in; end if;
                                when "00" => if data_mem_3_data_in(7) = '0' then DR <= x"000000" & data_mem_3_data_in; else DR <= x"ffffff" & data_mem_3_data_in; end if;
                                when others =>
                            end case;      
                        else
                            case A(1 downto 0) is
                                when "11" => if data_mem_0_data_in(7) = '0' then DR <= x"000000" & data_mem_0_data_in; else DR <= x"ffffff" & data_mem_0_data_in; end if;
                                when "10" => if data_mem_1_data_in(7) = '0' then DR <= x"000000" & data_mem_1_data_in; else DR <= x"ffffff" & data_mem_1_data_in; end if;
                                when "01" => if data_mem_2_data_in(7) = '0' then DR <= x"000000" & data_mem_2_data_in; else DR <= x"ffffff" & data_mem_2_data_in; end if;
                                when "00" => if data_mem_3_data_in(7) = '0' then DR <= x"000000" & data_mem_3_data_in; else DR <= x"ffffff" & data_mem_3_data_in; end if;
                                when others =>
                            end case;                        
                        end if;             
                     elsif i_decoded = ldrsh then
                        if p_bit = '1' then
                            case res(1) is
                                when '1' => if data_mem_1_data_in(7) = '0' then DR <= x"0000" & data_mem_1_data_in & data_mem_0_data_in; else DR <= x"ffff" & data_mem_1_data_in & data_mem_0_data_in; end if;
                                when '0' => if data_mem_3_data_in(7) = '0' then DR <= x"0000" & data_mem_3_data_in & data_mem_2_data_in; else DR <= x"ffff" & data_mem_3_data_in & data_mem_2_data_in; end if;
                                when others =>
                            end case; 
                        else
                            case A(1) is
                                when '1' => if data_mem_1_data_in(7) = '0' then DR <= x"0000" & data_mem_1_data_in & data_mem_0_data_in; else DR <= x"ffff" & data_mem_1_data_in & data_mem_0_data_in; end if;
                                when '0' => if data_mem_3_data_in(7) = '0' then DR <= x"0000" & data_mem_3_data_in & data_mem_2_data_in; else DR <= x"ffff" & data_mem_3_data_in & data_mem_2_data_in; end if;
                                when others =>
                            end case;                     
                        end if;                  
                     end if;
                when mem2RF =>
                    RF_wr_1_addr_inp <= IR(15 downto 12);
                    RF_wr_1_data_inp <= DR;
                    RF_wr_1_we <= '1';           
                when brn =>
                    --alu_op_1 <= X"000000" & "0" & pc(9 downto 2);
                    --alu_op_2 <= std_logic_vector(to_signed((to_integer(signed(IR(23 downto 0)))),32));
                    --alu_carry <= '1';
    --                if i_decoded = bne then
    --                   if z_flag = '0' then 
    --                    RF_pc_data_in <= alu_result(29 downto 0) & "00";
    --                   end if;  
    --                   if link_bit = '1' then
    --                    RF_wr_1_addr_inp <= "1110";
    --                    RF_wr_1_data_inp <= PC;
    --                    RF_wr_1_we <= '1';
    --                   end if; 
    --                elsif i_decoded = beq then
    --                   if z_flag = '1' then 
    --                    RF_pc_data_in <= alu_result(29 downto 0) & "00";
    --                   end if;
    --                   if link_bit = '1' then
    --                    RF_wr_1_addr_inp <= "1110";
    --                    RF_wr_1_data_inp <= PC;
    --                    RF_wr_1_we <= '1';
    --                   end if;                   
    --                else 
                        RF_pc_data_in <= alu_result(29 downto 0) & "00";   
                       if link_bit = '1' then
                         RF_wr_1_addr_inp <= "1110";
                         RF_wr_1_data_inp <= PC;
                         RF_wr_1_we <= '1';
                       end if;                           
    --                end if;
                    RF_pc_wea <= '1';
                    
                when exception_handler => 
                    RF_pc_wea <= '1';
                    CPSR(4 downto 0) <= supervisor_mode_encoding;
                    CPSR(7) <= '1';
                    -- check if r14_svc is being accessed
                    case exception_signal is
                        when Reset_exception => 
                            RF_pc_data_in <= reset_addr;
                        when SWI => 
                            RF_pc_data_in <= x"00" & IR(23 downto 0);
                            spsr_svc <= CPSR;
                            RF_wr_1_addr_inp <= "1110";
                            RF_wr_1_data_inp <= PC;
                            RF_wr_1_we <= '1';
                        when Undefined => 
                            RF_pc_data_in <= undef_addr;
                            spsr_svc <= CPSR;
                            RF_wr_1_addr_inp <= "1110";
                            RF_wr_1_data_inp <= PC;
                            RF_wr_1_we <= '1';
                        when IRQ_exception =>
                            RF_pc_data_in <= irq_addr;
                            spsr_svc <= CPSR;
                            RF_wr_1_addr_inp <= "1110";
                            RF_wr_1_data_inp <= PC;
                            RF_wr_1_we <= '1';
                        when others =>
                            -- do nothing
                    
                    end case;
                when arith_psr =>
                    if i_decoded = msr and IR(22) = '0' then 
                        if mode = supervisor then
                         cpsr <= B_reg;
                        elsif mode = user then
                          cpsr(31 downto 28) <= B_reg(31 downto 28);
                        end if; 
                    elsif i_decoded = msr and IR(22) = '1' and mode = supervisor then 
                        spsr_svc <= B_reg; -- doubtful\
                    elsif i_decoded = mrs and IR(22)='0' then
                         RF_wr_1_addr_inp <= IR(15 downto 12);
                         RF_wr_1_data_inp <= cpsr;
                         RF_wr_1_we <= '1';
                    elsif i_decoded = mrs and IR(22)='1' and mode = supervisor then
                          RF_wr_1_addr_inp <= IR(15 downto 12);
                          RF_wr_1_data_inp <= spsr_svc;
                          RF_wr_1_we <= '1';               
                    end if;      	
                when skip =>
                    if (instr_class = DP or instr_class = DP_mull) and s_bit = '1' then 
                        cpsr(31) <= n_flag;
                        cpsr(30) <= z_flag;
                        cpsr(29) <= c_flag;
                        cpsr(28) <= v_flag;
                    end if;
                when others =>    
                        -- do nothing    
            end case;
        end if;
        end if;
    end if;
end process;
end cpu_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use work.common_type.all;

entity main_bus is 
    port(
        clk : IN std_logic;
        reset, exception_reset, step, go, instr : IN std_logic;
		-- disp_option : IN std_logic; --disp_option 0 for lower 16 bits and 1 for higher 16 bits
        register_select : IN std_logic_vector(3 downto 0); 
        PC, RF_data_out, instruction : out std_logic_vector(31 downto 0);
        keypad_row_input : IN std_logic_vector(3 downto 0);
        keypad_driver : out std_logic_vector(3 downto 0);
		cathode_output : out std_logic_vector(6 downto 0);
		anode_output : out std_logic_vector(3 downto 0)
    );

end main_bus;

architecture main_bus_arch of main_bus is
--signal data_mem_0_data_in,data_mem_0_data_out,data_mem_1_data_in,data_mem_1_data_out,data_mem_2_data_in,data_mem_2_data_out,data_mem_3_data_in,data_mem_3_data_out: std_logic_vector(7 downto 0);  
---- 0 denotes the least significant 8 bits of data_memory
--signal data_mem_data_out, data_mem_data_in : std_logic_vector(31 downto 0);
--signal data_mem_add_to_data_m : std_logic_vector(31 downto 0);
signal write : std_logic;
signal address : std_logic_vector(31 downto 0);
signal read_data : std_logic_vector(31 downto 0);
signal write_data : std_logic_vector(31 downto 0);
signal cathode_reg : std_logic_vector(15 downto 0) := x"0000";
signal anode_reg : std_logic_vector(3 downto 0) := "1111";
signal irq_output, irq_ack_output : std_logic;
signal exception_output : exception_type;
signal mode: display_mode_type := none;
SIGNAL control_state_output : CONTROL_STATE_TYPE;
signal access_mode : mode_type;
signal is_valid_output : std_logic;
signal keypad_driver_signal, keypad_key_decoded_signal : std_logic_vector(3 downto 0);
signal is_key_pressed : std_logic := '0';
component display is
Port ( 
    Num_to_be_displayed : IN std_logic_vector(15 downto 0);
	anode_pattern : IN std_logic_vector(3 downto 0);
	cathode_output : OUT std_logic_vector(6 downto 0);
	anode_output : OUT std_logic_vector(3 downto 0)
);
end component;

component keypad_driver_generator is
Port ( 
    clk : in std_logic; 
    keypad_driver_output : out std_logic_vector(3 downto 0)
);
end component;

component keypad_key_decoder is
PORT(
	clk : IN std_logic;
	keypad_driver : IN std_logic_vector(3 DOWNTO 0);
	keypad_row : IN std_logic_vector(3 DOWNTO 0);
	key_pressed : OUT std_logic;
	keypad_key_decoded : OUT std_logic_vector(3 downto 0)
	);
end component;

begin
cpu:entity work.CPU(CPU_arch) PORT MAP( 
                                        clk => clk,
                                        reset => reset,
                                        exception_reset => exception_reset,
                                        step => step,
                                        go => go,
                                        instr => instr, 
                                        program_select => "000",
                                        register_select => register_select,
                                        add_to_program_m => PC,
                                        add_to_data_m => address,
                                        data_out => write_data,
                                        RF_data_out => RF_data_out,
                                        instruction_disp => instruction,
                                        data_in => read_data, 
										memory_wea => write,
										irq_output => irq_output,
										irq_ack_output => irq_ack_output,
										exception_output => exception_output,
										control_state_output => control_state_output,
										mode_output => access_mode,
										is_valid_output => is_valid_output,
										keypad_is_key_pressed => is_key_pressed,
										keypad_key_decoded => keypad_key_decoded_signal
                                        );
display_instance: display port map(
    Num_to_be_displayed => cathode_reg,
    anode_pattern => anode_reg,
    cathode_output => cathode_output,
    anode_output => anode_output
);				

keypad_driver_instance: keypad_driver_generator port map(
	clk => clk,
	keypad_driver_output => keypad_driver_signal
);

keypad_key_decoder_instance: keypad_key_decoder port map(
	clk => clk,
	keypad_driver => keypad_driver_signal,
	keypad_row => keypad_row_input,
	key_pressed => is_key_pressed,
	keypad_key_decoded => keypad_key_decoded_signal
);

keypad_driver <= keypad_driver_signal;
mode <= multiple when address = x"00000000" and write_data(1 downto 0) = "01" and write = '1'
        else single when address = x"00000000" and write_data(1 downto 0) = "10" and write = '1'
        else read when address = x"00000000" and write_data(1 downto 0) = "11" and write = '1';
--cathode_reg <= write_data(15 downto 0) when write = '1' and (address = x"0000000" & "0100");
--anode_reg <= write_data(4 downto 0) when write = '1' and (address = x"0000000" & "1000");
process(clk)
begin
     if rising_edge(clk) then
--		if address = x"0000000" & "0100" then	
--			case (write_mem_1 & write_mem_0) is
--				when "11" => cathode_reg <= write_data(15 downto 0);
--				when "10" => cathode_reg(15 downto 8) <= write_data(7 downto 0);
--				when "01" => cathode_reg(7 downto 0) <= write_data(7 downto 0);
--				when others => --do nothing
--			end case;
--		elsif address = x"00000000" then
--			if write_mem_2 = '1' then
--				anode_reg <= write_data(7 downto 0);
--			end if;
--		end if;	
        if write = '1' then 
            if (address = x"0000000" & "0100") then
                if mode = multiple then
                    cathode_reg <= write_data(15 downto 0);
                elsif mode = single then
                    cathode_reg <= write_data(3 downto 0) & write_data(3 downto 0) & write_data(3 downto 0) & write_data(3 downto 0);
                end if;
            elsif (address = x"0000000" & "1000") then
                anode_reg <= write_data(3 downto 0);
            end if;    
        end if;
    end if;
end process;


end main_bus_arch;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;

--entity LED_Display is
--    port (
--        disp_choice,wr_addr_inp :in std_logic_vector(3 downto 0);
--        program_address, program_instr, data_address, data_stored, data_retrieved, state, register_val : in  std_logic_vector(31 downto 0);
--        led_output : out std_logic_vector(15 downto 0)
--    );
--end LED_Display;

--architecture display of LED_display is
--begin
--    led_output <= state(15 downto 0) when disp_choice = "0000"
--                else program_address(31 downto 16) when disp_choice = "1001"
--                else program_address(15 downto 0) when disp_choice = "0001"
--                else program_instr(31 downto 16) when disp_choice = "1010"
--                else program_instr(15 downto 0) when disp_choice = "0010"
--                else data_address(31 downto 16) when disp_choice = "1011"
--                else data_address(15 downto 0) when disp_choice = "0011"
--                else data_stored(31 downto 16) when disp_choice = "1100"
--                else data_stored(15 downto 0) when disp_choice = "0100"
--                else data_retrieved(31 downto 16) when disp_choice = "1101"
--                else data_retrieved(15 downto 0) when disp_choice = "0101"
--                else register_val(31 downto 16) when disp_choice = "1110"
--                else register_val(15 downto 0) when disp_choice = "0110"
--                else X"000" & wr_addr_inp when disp_choice = "0111"
--                else "0000000000000000";
--end display;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;

--entity frequency_divider is
--    port(
--        clk : in std_logic;
--        clk_divided : out std_logic
--    );
--end frequency_divider;

--architecture frequency_divider_arch of frequency_divider is
--signal clk_counter :  integer := 0;
--signal clk_divided_signal : std_logic;
--begin
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            clk_counter <= clk_counter + 1;
--        end if;
--        if (clk_counter = 500000) then
--            clk_counter <= 0;
--            clk_divided_signal <= not clk_divided_signal;
--        end if;
--    end process;
--    clk_divided <= clk_divided_signal;
--end frequency_divider_arch;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;

--entity debouncer is
--    port(
--        reset_button,step_button,go_button,instr_button,clk_divided,exception_reset : in std_logic;
--        reset_debounced,step_debounced,go_debounced,instr_debounced,exception_reset_debounced : out std_logic
--    );
--end debouncer;

--architecture debouncer_arch of debouncer is
--signal reset_signal, step_signal, go_signal, instr_signal : std_logic := '0';

--begin
--    process(clk_divided)
--    begin
--        if rising_edge(clk_divided) then
--            reset_signal <= reset_button;
--            step_signal <= step_button;
--            go_signal <= go_button;
--            instr_signal <= instr_button;
--        end if;
--    end process;
--    instr_debounced <= instr_signal;
--    reset_debounced <= reset_signal;
--    step_debounced <= step_signal;
--    go_debounced <= go_signal;
--end debouncer_arch;


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;
--entity main is 
--port(
--    clk,reset,step,go,instr,exception_reset:in std_logic;
--    program_select:in std_logic_vector(2 downto 0);
--    disp_choice:in std_logic_vector(3 downto 0);
--    register_select: in std_logic_vector(3 downto 0);
--    LED:out std_logic_vector(15 downto 0);
--    cathode_output : out std_logic_vector(6 downto 0);
--    anode_output : out std_logic_vector(3 downto 0);
--	keypad_row_input : in std_logic_vector(3 downto 0);
--	keypad_driver : out std_logic_vector(3 downto 0)
--);
--end main;

--architecture behavioral of main is
--signal reset_temp,we,step_temp,go_temp,slow_clk,instr_temp,exception_reset_temp: std_logic;
--signal instruction,data_in,add_to_data_m,data_out  : std_logic_vector(31 downto 0); --:= "00000000000000000000000000000000";
--signal add_to_program_m,state_temp,register_val :std_logic_vector(31 downto 0);
--signal state : std_logic_vector(1 downto 0);
--signal wr_addr_inp:std_logic_vector(3 downto 0);
--signal RF_data_out : std_logic_vector(31 downto 0);

--begin
--state_temp <= "000000000000000000000000000000" & state(1 downto 0);
--clk_slow:entity work.frequency_divider (frequency_divider_arch) PORT MAP(clk,slow_clk);
--debounce:entity work.debouncer (debouncer_arch) PORT MAP(reset,step,go,instr,slow_clk,exception_reset,reset_temp,step_temp,go_temp,instr_temp,exception_reset_temp);
----cpu:entity work.CPU(CPU_arch) PORT MAP(clk,reset_temp,step_temp,go_temp,instr_temp,program_select,register_select,add_to_program_m,add_to_data_m,data_out,RF_data_out,instruction,state,wr_addr_inp);
--dis:entity work.LED_display(display) PORT MAP(disp_choice,wr_addr_inp,add_to_program_m,instruction,add_to_data_m,data_out,data_in,state_temp,RF_data_out,LED);
--bus_main: entity work.main_bus(main_bus_arch) PORT MAP(
--        clk => clk,
--        reset => reset_temp,
--        exception_reset => exception_reset_temp,
--        step => step_temp,
--        go => go_temp, 
--        instr => instr_temp,
--        register_select => register_select,
--        PC => add_to_program_m,
--        RF_data_out => RF_data_out, 
--        instruction => instruction,
--		cathode_output => cathode_output,
--		anode_output => anode_output,
--		keypad_row_input => keypad_row_input,
--		keypad_driver => keypad_driver
--);

--end behavioral;