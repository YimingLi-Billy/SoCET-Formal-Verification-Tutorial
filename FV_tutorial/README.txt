Formal Verification w/ JasperGold

1. Contents
- FV_totorial:
	- FV_Design_BringUp.MOV: a video walkthrough for the design bring up
	- elevator_top.v: a compilable verilog design file.
	- rak_JasperGold_design_bringup.pdf: a written instruction of the design bring up provided by 
		Cadence Support.
	- solution: 
		- elevator_top.tcl: a compilable verilog design file with properties
		- run_elevator_top.tcl
		- Design_Overview.jpg

		* user may copy this and the following contents into elevator_top.tcl / run_elevator_top.tcl during practice.
		- sva_cover_properties.txt
		- sva_door_controller_properties.txt
		- sva_checker_properties.txt
		- sva_input_properties.txt
		- run_elevator_top.tcl
		- assert_to_assume.tcl


2. Usasge
The user may practice formal verification using the design file provided. For practice, 
JasperGold should be run in current directory.


3. Things not Included in the Video
- The user needs to fix a warning when first run JasperGold.
	This is caused by a typo in the design file: line 9: cfg_rd_data should be an output
- The video doesn't include usage of sva_door_controller_properties.txt, the user may use it for own practice.
- Assert properties is still violated after fixing the last typo:
	This is caused by 'current_floor' value rollover, it could be fixed by adding upperbound and lowerbound contraints 
	to 'current_floor'. For example:

ast_elevator_top_input_current_floor_lb: assert property(current_floor==0 |-> (elevator_control!=ELEV_MOTOR_DOWN & STATE!=ELEVATOR_DOWN))
				else $display ("ERROR: current_floor over bound");
ast_elevator_top_input_current_floor_ub: assert property(current_floor==4'b1111 |-> (elevator_control!=ELEV_MOTOR_UP & STATE!=ELEVATOR_UP))
				else $display ("ERROR: current_floor over bound");


4. Acknowledgement
All design related files are properties of Cadence Support. 