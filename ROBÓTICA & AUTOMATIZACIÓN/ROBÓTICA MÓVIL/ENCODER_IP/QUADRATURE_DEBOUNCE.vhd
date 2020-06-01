--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez											 						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	QUADRATURE_DEBOUNCE.vhd																	--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	Takes the A and B channels from a quadrature encoder and it synchronizes	--
--									them with the clock input and it debounces the inputs according to the 		--
--									cycles defined by DEBOUNCE_CYCLES + 2													--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY QUADRATURE_DEBOUNCE IS
	GENERIC (
				DEBOUNCE_CYCLES	:	POSITIVE := 5	-- Number of cycles to debounce from the encoder channels (DEBOUNCE_CYCLES + 2)
	); 	
	PORT (
			CLK			:	IN	 STD_LOGIC;		--Clock signal
			A				:	IN	 STD_LOGIC;		--Channel A from the encoder
			B				:	IN	 STD_LOGIC; 		--Channel B from the encoder
			A_DEBOUNCED	:  OUT STD_LOGIC;		--Debounced channel A from the encoder
			B_DEBOUNCED	:  OUT STD_LOGIC		--Debounced channel A from the encoder
	);
END QUADRATURE_DEBOUNCE;

ARCHITECTURE LOGIC OF QUADRATURE_DEBOUNCE IS

	SIGNAL	A_NEW 				:	STD_LOGIC_VECTOR(1 DOWNTO 0);			--SYNCHRONIZER/DEBOUNCE REGISTERS FOR ENCODED SIGNAL A
	SIGNAL	B_NEW					:	STD_LOGIC_VECTOR(1 DOWNTO 0); 		--SYNCHRONIZER/DEBOUNCE REGISTERS FOR ENCODED SIGNAL B
	SIGNAL	A_PREV				:	STD_LOGIC;									--LAST PREVIOUS STABLE VALUE OF ENCODED SIGNAL A
	SIGNAL	B_PREV				:	STD_LOGIC;									--LAST PREVIOUS STABLE VALUE OF ENCODED SIGNAL B
	SIGNAL	DEBOUNCE_CNT		:	INTEGER RANGE 0 TO DEBOUNCE_CYCLES;	--TIMER TO REMOVE GLITCHES AND VALIDATE STABLE VALUES OF INPUTS

BEGIN

	--------------------------------------------------------------------------------------------	
	-- SYNCHRONIZE AND DEBOUNCE THE SIGNALS COMMING FROM THE A AND B CHANNELS OF THE ENCODER  --
	--------------------------------------------------------------------------------------------
	PROCESS(CLK)
	BEGIN
		IF(RISING_EDGE(CLK)) THEN
			A_NEW <= A_NEW(0) & A;																--SHIFT IN NEW VALUES OF 'A'	
			B_NEW <= B_NEW(0) & B;																--SHIFT IN NEW VALUES OF 'B'
			IF(((A_NEW(0) XOR A_NEW(1)) OR (B_NEW(0) XOR B_NEW(1))) = '1') THEN	--A INPUT OR B INPUT IS CHANGING
				DEBOUNCE_CNT <= 0;															   --CLEAR DEBOUNCE COUNTER
			ELSIF(DEBOUNCE_CNT = DEBOUNCE_CYCLES) THEN									--DEBOUNCE TIME IS MET
				A_PREV <= A_NEW(1);																--UPDATE VALUE OF A_PREV
				B_PREV <= B_NEW(1);																--UPDATE VALUE OF B_PREV
			ELSE																						--DEBOUNCE TIME IS NOT YET MET		
				DEBOUNCE_CNT <= DEBOUNCE_CNT + 1;											--INCREMENT DEBOUNCE COUNTER
			END IF;			
		END IF;
	END PROCESS;
	
	A_DEBOUNCED <= A_PREV;
	B_DEBOUNCED <= B_PREV;
	--------------------------------------------------------------------------------------------
END LOGIC;
