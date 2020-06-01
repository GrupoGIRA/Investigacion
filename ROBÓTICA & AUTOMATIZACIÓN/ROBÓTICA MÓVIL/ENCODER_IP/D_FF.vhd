--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez 											  						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	D_FF.vhd																							--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	D Flip-Flop with synchronous set and preset signals								--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY D_FF IS
	PORT (
			RST : IN  STD_LOGIC;		--Reset
			PST : IN  STD_LOGIC;		--Preset
			D 	 : IN  STD_LOGIC;		--Input
			CLK : IN  STD_LOGIC;		--Clock
			Q 	 : OUT STD_LOGIC;		--Output
			QB  : OUT STD_LOGIC		--Inverse output
	);
END ENTITY D_FF;
 
ARCHITECTURE BEHAVIORAL OF D_FF IS
BEGIN
	---------------------------------------------------------------
	-- D FLIP FLOP DESCRIPTION WITH SYNCHRONOUS RESET AND PRESET --
	---------------------------------------------------------------
   PROCESS (CLK,RST,PST) IS
   BEGIN 
		IF RISING_EDGE(CLK) THEN 
			IF (RST = '1') THEN   
				Q  <= '0';
				QB <= '1';
			ELSIF (PST = '1') THEN
				Q  <= '1';
				QB <= '0';
			ELSE
				Q  <= D;
				QB <= NOT(D);
			END IF;
		END IF;
   END PROCESS;
	---------------------------------------------------------------
END BEHAVIORAL;