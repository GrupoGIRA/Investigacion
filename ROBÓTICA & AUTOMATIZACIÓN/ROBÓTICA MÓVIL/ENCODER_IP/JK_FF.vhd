--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Retrieved from https://allaboutfpga.com/vhdl-code-flipflop-d-t-jk-sr/		--
--		Institution			:	N/A																								--
--		Entity				:	N/A																								--
--																																		--
--		FileName				:	JK_FF.vhd																						--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	JK Flip-Flop without reset or preset signals											--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
 
ENTITY JK_FF IS
	PORT (
			J,K,CLOCK : IN STD_LOGIC;		--J and K inputs and clock	
			Q		 	 : OUT STD_LOGIC		--Output
	);
END JK_FF;
 
ARCHITECTURE BEHAVIORAL OF JK_FF IS
BEGIN
   ------------------------------
	-- JK FLIP FLOP DESCRIPTION --
	------------------------------
	PROCESS(CLOCK)
		VARIABLE TMP: STD_LOGIC;
	BEGIN
		IF(RISING_EDGE(CLOCK)) THEN
			IF(J='0' AND K='0')THEN
				TMP:=TMP;
			ELSIF(J='1' AND K='1')THEN
				TMP:= NOT TMP;
			ELSIF(J='0' AND K='1')THEN
				TMP:='0';
			ELSE
				TMP:='1';
			END IF;
		END IF;
		Q<=TMP;
	END PROCESS;
	------------------------------
END BEHAVIORAL;