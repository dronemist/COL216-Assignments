## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
#Bank = 34, Pin name = ,					Sch name = CLK100MHZ
		set_property PACKAGE_PIN W5 [get_ports clk]
		set_property IOSTANDARD LVCMOS33 [get_ports clk]
		create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

set_property PACKAGE_PIN U17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN U18 [get_ports step]
set_property IOSTANDARD LVCMOS33 [get_ports step]

set_property PACKAGE_PIN W19 [get_ports go]
set_property IOSTANDARD LVCMOS33 [get_ports go]

set_property PACKAGE_PIN T17 [get_ports instr]
set_property IOSTANDARD LVCMOS33 [get_ports instr]

set_property PACKAGE_PIN T18 [get_ports exception_reset]
set_property IOSTANDARD LVCMOS33 [get_ports exception_reset]

set_property PACKAGE_PIN V17 [get_ports {program_select[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {program_select[0]}]

set_property PACKAGE_PIN V16 [get_ports {program_select[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {program_select[1]}]

set_property PACKAGE_PIN W16 [get_ports {program_select[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {program_select[2]}]

set_property PACKAGE_PIN W2 [get_ports {disp_choice[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {disp_choice[0]}]

set_property PACKAGE_PIN U1 [get_ports {disp_choice[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {disp_choice[1]}]

set_property PACKAGE_PIN T1 [get_ports {disp_choice[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {disp_choice[2]}]

set_property PACKAGE_PIN R2 [get_ports {disp_choice[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {disp_choice[3]}]

set_property PACKAGE_PIN W15 [get_ports {register_select[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {register_select[0]}]

set_property PACKAGE_PIN V15 [get_ports {register_select[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {register_select[1]}]

set_property PACKAGE_PIN W14 [get_ports {register_select[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {register_select[2]}]

set_property PACKAGE_PIN W13 [get_ports {register_select[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {register_select[3]}]

set_property PACKAGE_PIN L1 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]

set_property PACKAGE_PIN P1 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]

set_property PACKAGE_PIN N3 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]

set_property PACKAGE_PIN P3 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

set_property PACKAGE_PIN U3 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]

set_property PACKAGE_PIN W3 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]

set_property PACKAGE_PIN V3 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]

set_property PACKAGE_PIN V13 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]

set_property PACKAGE_PIN V14 [get_ports {LED[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]

set_property PACKAGE_PIN U14 [get_ports {LED[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]

set_property PACKAGE_PIN U15 [get_ports {LED[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]

set_property PACKAGE_PIN W18 [get_ports {LED[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]

set_property PACKAGE_PIN V19 [get_ports {LED[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]

set_property PACKAGE_PIN U19 [get_ports {LED[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]

set_property PACKAGE_PIN E19 [get_ports {LED[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]

set_property PACKAGE_PIN U16 [get_ports {LED[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]

set_property PACKAGE_PIN W7 [get_ports {cathode_output[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[0]}]

set_property PACKAGE_PIN W6 [get_ports {cathode_output[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[1]}]

set_property PACKAGE_PIN U8 [get_ports {cathode_output[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[2]}]

set_property PACKAGE_PIN V8 [get_ports {cathode_output[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[3]}]

set_property PACKAGE_PIN U5 [get_ports {cathode_output[4]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[4]}]

set_property PACKAGE_PIN V5 [get_ports {cathode_output[5]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[5]}]

set_property PACKAGE_PIN U7 [get_ports {cathode_output[6]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_output[6]}]

#set_property PACKAGE_PIN V7 [get_ports dp]							
#	set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN U2 [get_ports {anode_output[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {anode_output[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode_output[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {anode_output[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode_output[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {anode_output[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode_output[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {anode_output[3]}]

set_property PACKAGE_PIN J1 [get_ports {keypad_driver[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_driver[0]}]

set_property PACKAGE_PIN L2 [get_ports {keypad_driver[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_driver[1]}]

set_property PACKAGE_PIN J2 [get_ports {keypad_driver[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_driver[2]}]

set_property PACKAGE_PIN G2 [get_ports {keypad_driver[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_driver[3]}]

set_property PACKAGE_PIN H1 [get_ports {keypad_row_input[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_input[0]}]

set_property PACKAGE_PIN K2 [get_ports {keypad_row_input[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_input[1]}]

set_property PACKAGE_PIN H2 [get_ports {keypad_row_input[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_input[2]}]

set_property PACKAGE_PIN G3 [get_ports {keypad_row_input[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_input[3]}]

#set_property PACKAGE_PIN V14 [get_ports {[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[8]}]

#set_property PACKAGE_PIN U14 [get_ports {finalLED[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[9]}]

#set_property PACKAGE_PIN U15 [get_ports {finalLED[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[10]}]

#set_property PACKAGE_PIN W18 [get_ports {finalLED[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[11]}]

#set_property PACKAGE_PIN V19 [get_ports {finalLED[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[12]}]

#set_property PACKAGE_PIN U19 [get_ports {finalLED[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[13]}]

#set_property PACKAGE_PIN E19 [get_ports {finalLED[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[14]}]

#set_property PACKAGE_PIN U16 [get_ports {finalLED[15]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalLED[15]}]

#set_property PACKAGE_PIN V17 [get_ports {finalset[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalset[0]}]

#set_property PACKAGE_PIN V16 [get_ports {finalset[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalset[1]}]

#set_property PACKAGE_PIN W16 [get_ports {finalset[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalset[2]}]

#set_property PACKAGE_PIN W17 [get_ports {finalset[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {finalset[3]}]

####7 segment
#set_property PACKAGE_PIN W7 [get_ports {finalSS[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[0]}]

#set_property PACKAGE_PIN W6 [get_ports {finalSS[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[1]}]

#set_property PACKAGE_PIN U8 [get_ports {finalSS[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[2]}]

#set_property PACKAGE_PIN V8 [get_ports {finalSS[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[3]}]

#set_property PACKAGE_PIN U5 [get_ports {finalSS[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[4]}]

#set_property PACKAGE_PIN V5 [get_ports {finalSS[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[5]}]

#set_property PACKAGE_PIN U7 [get_ports {finalSS[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {finalSS[6]}]

##set_property PACKAGE_PIN V7 [get_ports dp]							
##	set_property IOSTANDARD LVCMOS33 [get_ports dp]

#set_property PACKAGE_PIN U2 [get_ports {anode[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
#set_property PACKAGE_PIN U4 [get_ports {anode[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
#set_property PACKAGE_PIN V4 [get_ports {anode[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
#set_property PACKAGE_PIN W4 [get_ports {anode[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]



## Others (BITSTREAM, CONFIG)
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property CONFIG_MODE SPIx4 [current_design]

#set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

#set_property CONFIG_VOLTAGE 3.3 [current_design]
#set_property CFGBVS VCCO [current_design]