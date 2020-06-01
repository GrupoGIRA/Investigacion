--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez											 						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	DIRECTION_RESET.vhd																			--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	Generates a signal at the moment of change in direction in the encoder		--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY DIRECTION_RESET IS
	PORT (
			Ap			 : IN  STD_LOGIC;		--short pulse produced in the rising and falling edge of A
			Bp			 : IN  STD_LOGIC;		--short pulse produced in the rising and falling edge of B
			F_quad 	 :	IN  STD_LOGIC;		--signal 4 times the encoder resolution
			reset_dir : OUT STD_LOGIC		--direction reset
		);
END DIRECTION_RESET;

ARCHITECTURE MAIN OF DIRECTION_RESET IS

	COMPONENT D_FF IS
		PORT (
				RST : IN  STD_LOGIC;		--Reset
				PST : IN  STD_LOGIC;		--Preset
				D 	 : IN  STD_LOGIC;		--Input
				CLK : IN  STD_LOGIC;		--Clock
				Q 	 : OUT STD_LOGIC;		--Output
				QB  : OUT STD_LOGIC		--Inverse output
		);
	END COMPONENT;
	
	--Signals to determine the reset_dir output
	SIGNAL Ap_D1 : STD_LOGIC;
	SIGNAL Ap_D2 : STD_LOGIC;
	SIGNAL Bp_D1 : STD_LOGIC;
	SIGNAL Bp_D2 : STD_LOGIC;
	
BEGIN
	--------------------------------------------------------------------	
	-- GENERATE SIGNAL AT THE PRECISE TIME OF REVERSAL OF DIRECTION 	--
	--------------------------------------------------------------------
	D_1 : D_FF PORT MAP ('0', '0', Ap, 	  F_quad, Ap_D1);
	D_2 : D_FF PORT MAP ('0', '0', Bp, 	  F_quad, Bp_D1);
	D_3 : D_FF PORT MAP ('0', '0', Ap_D1, F_quad, Ap_D2);
	D_4 : D_FF PORT MAP ('0', '0', Bp_D1, F_quad, Bp_D2);
	reset_dir <= ((Ap_D1 AND Ap_D2) OR (Bp_D1 AND Bp_D2));
	--------------------------------------------------------------------
END MAIN;