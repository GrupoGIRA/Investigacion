--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez																	--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	OUTPUT_FORMING_CIRCUIT.vhd																	--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	Takes the direction error and reset direction signals in order to output   --
--									a signal at the moment of change in direction in the encoder					--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY OUTPUT_FORMING_CIRCUIT IS
	PORT (
			Dir_error : IN  STD_LOGIC;		--signal that detect an error in the direction
			reset_dir : IN  STD_LOGIC;		--direction reset
			CLK		 : IN  STD_LOGIC;		--system clock
			Direction : OUT STD_LOGIC		--Direction of rotation
	);		
END OUTPUT_FORMING_CIRCUIT;

ARCHITECTURE MAIN OF OUTPUT_FORMING_CIRCUIT IS
	
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
	
	--Signals to interconnect the modules
	SIGNAL Dir  : STD_LOGIC;	
	SIGNAL Q_D  : STD_LOGIC;
	SIGNAL QB_D : STD_LOGIC;

BEGIN
	-------------------------------------------------------------------------------------	
	-- OUTPUT THE DIRECTION OF ROTATION TAKING INTO ACCOUNT THE DETECTED ERROR		     --
	-------------------------------------------------------------------------------------
	D_1 : D_FF PORT MAP ('0', '0', Dir_error, reset_dir, Q_D, QB_D);
	D_2 : D_FF PORT MAP (Q_D, QB_D, Dir_error, CLK, Dir);	
	Direction <= Dir;
	-------------------------------------------------------------------------------------
END MAIN;