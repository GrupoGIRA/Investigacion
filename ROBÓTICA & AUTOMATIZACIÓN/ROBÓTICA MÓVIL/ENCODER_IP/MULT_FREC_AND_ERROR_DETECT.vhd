--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez 											 						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	MULT_FREC_AND_ERROR_DETECT.vhd															--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	Takes the A and B channels of a quadrature encoder and multiplies by 4 the	--
--									frequency of the signals taking also into account the error in detection	--
--									when a there is a change in the direction of rotation					 			--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY MULT_FREC_AND_ERROR_DETECT IS
	PORT (
			CLK		 : IN  	 STD_LOGIC;		--system clock
			A			 : IN  	 STD_LOGIC;		--quadrature encoded signal a
			B			 : IN  	 STD_LOGIC;  	--quadrature encoded signal b
			Ap			 : BUFFER STD_LOGIC;		--short pulse produced in the rising and falling edge of A
			Bp			 : BUFFER STD_LOGIC;		--short pulse produced in the rising and falling edge of B
			Dir_error : OUT 	 STD_LOGIC;		--signal that detect an error in the direction
			F_quad 	 :	OUT 	 STD_LOGIC		--signal 4 times the encoder resolution
		);
END MULT_FREC_AND_ERROR_DETECT;

ARCHITECTURE MAIN OF MULT_FREC_AND_ERROR_DETECT IS

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
	
	COMPONENT JK_FF
		PORT (
				J,K,CLOCK : IN STD_LOGIC;		--J and K inputs and clock	
				Q		 	 : OUT STD_LOGIC		--Output
		);
	END COMPONENT;
	
	-- Signal to interconnect the modules
	SIGNAL Adly : STD_LOGIC;
	SIGNAL Bdly : STD_LOGIC;	

BEGIN
	
	-------------------------------------------------------------------------------------	
	-- MULTIPLY THE FREQUENCY AND DETECT THE ERROR IN THE DIRECTION CHANGES				  --
	-------------------------------------------------------------------------------------
	D_1 : D_FF PORT MAP ('0', '0', A, CLK, Adly);
	D_2 : D_FF PORT MAP ('0', '0', B, CLK, Bdly);
	Ap <= A XOR Adly;
	Bp <= B XOR Bdly;
	F_quad <= Ap OR Bp;
	JK_1 : JK_FF PORT MAP ((Ap AND (A XOR B)), (Bp AND (A XOR B)), CLK, Dir_error);
	-------------------------------------------------------------------------------------
END MAIN;