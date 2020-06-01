--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez											  						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	QUADRATURE_DECODER.vhd																	--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	Uses the MULT_FREC_AND_ERROR_DETECT.vhd, DIRECTION_RESET.vhd and 				--
--									OUTPUT_FORMING_CIRCUIT.vhd files in order to take the A and B channels 		--
--									from a quadrature encoder and use this information to multiply by four 		--
--									the frequency of the input and detect the direction of rotation reducing	--
--									the errors when there is a change in the rotation									--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY QUADRATURE_DECODER IS
	PORT (
			CHANNEL_A : IN  STD_LOGIC;		--Channel A from the encoder
			CHANNEL_B : IN  STD_LOGIC;		--Channel B from the encoder
			CLK 		 : IN  STD_LOGIC;		--Clock signal
			x4_A_B	 : OUT STD_LOGIC;		--Signal with four times the frequency of A and B
			Direction : OUT STD_LOGIC		--Signal representing the direction of rotation
	);		
END QUADRATURE_DECODER;

ARCHITECTURE MAIN OF QUADRATURE_DECODER IS
	
	COMPONENT MULT_FREC_AND_ERROR_DETECT
		PORT (
				CLK		 : IN  	 STD_LOGIC;		--system clock
				A			 : IN  	 STD_LOGIC;		--quadrature encoded signal a
				B			 : IN  	 STD_LOGIC;  	--quadrature encoded signal b
				Ap			 : BUFFER STD_LOGIC;		--short pulse produced in the rising and falling edge of A
				Bp			 : BUFFER STD_LOGIC;		--short pulse produced in the rising and falling edge of B
				Dir_error : OUT 	 STD_LOGIC;		--signal that detect an error in the direction
				F_quad 	 :	OUT 	 STD_LOGIC		--signal 4 times the encoder resolution
		);
	END COMPONENT;
	
	COMPONENT DIRECTION_RESET
		PORT (
				Ap			 : IN  STD_LOGIC;		--short pulse produced in the rising and falling edge of A
				Bp			 : IN  STD_LOGIC;		--short pulse produced in the rising and falling edge of B
				F_quad 	 :	IN  STD_LOGIC;		--signal 4 times the encoder resolution
				reset_dir : OUT STD_LOGIC		--direction reset
		);
	END COMPONENT;
	
	COMPONENT OUTPUT_FORMING_CIRCUIT 
		PORT (
				Dir_error : IN  STD_LOGIC;		--signal that detect an error in the direction
				reset_dir : IN  STD_LOGIC;		--direction reset
				CLK		 : IN  STD_LOGIC;		--system clock
				Direction : OUT STD_LOGIC		--Direction of rotation
		);		
	END COMPONENT;
		
	--Signals to interconnect the modules
	SIGNAL Ap_s 			: STD_LOGIC;
	SIGNAL Bp_s				: STD_LOGIC;
	SIGNAL Dir_error_s	: STD_LOGIC;	
	SIGNAL F_quad_s		: STD_LOGIC;
	SIGNAL reset_dir_s	: STD_LOGIC;
	SIGNAL Up				: STD_LOGIC;
	SIGNAL Down				: STD_LOGIC;
	
BEGIN
	-------------------------------------------------------------------------------------	
	-- MULTIPLY THE FREQUENCY AND DETECT THE ERROR IN THE DIRECTION CHANGES				  --
	-------------------------------------------------------------------------------------
	PHASE_1 : MULT_FREC_AND_ERROR_DETECT PORT MAP (CLK, CHANNEL_A, CHANNEL_B, Ap_s, Bp_s, Dir_error_s, F_quad_s);
	x4_A_B <= F_quad_s;
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------	
	-- GENERATE SIGNAL AT THE PRECISE TIME OF REVERSAL OF DIRECTION 						  --
	-------------------------------------------------------------------------------------
	PHASE_2 : DIRECTION_RESET PORT MAP (Ap_s, Bp_s, F_quad_s, reset_dir_s);
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------	
	-- OUTPUT THE DIRECTION OF ROTATION TAKING INTO ACCOUNT THE DETECTED ERROR		     --
	-------------------------------------------------------------------------------------
	PHASE_3 : OUTPUT_FORMING_CIRCUIT PORT MAP (Dir_error_s, reset_dir_s, CLK, Direction);
	-------------------------------------------------------------------------------------
END MAIN;