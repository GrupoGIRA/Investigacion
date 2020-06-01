--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez											  						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	QUADRATURE_ENCODER_COUNTER.vhd															--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	It takes the signal four times the frequency of the channels A and B of		--
--									a quadrature encoder and according to the signal of direction it counts 	--
--									up or down																						--
--																																		--
--		Version History																											--
--   	Version 1.0 04/05/2020 Andres-David Suarez-Gomez																--
--    Initial test in the UPTCRover5v2 project																			--
--    																																--
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY QUADRATURE_ENCODER_COUNTER IS
	GENERIC (
				N 						: POSITIVE := 8;	-- Number of bits of the counter for the encoder pulses
				DEBOUNCE_CYCLES 	: POSITIVE := 5	-- Number of cycles to debounce from the encoder channels
	);
	PORT (
				CHANNEL_A 	: IN  STD_LOGIC;								--Channel A from the encoder
				CHANNEL_B 	: IN  STD_LOGIC;								--Channel B from the encoder
				CLK 			: IN  STD_LOGIC;								--Clock signal
				RESET 		: IN  STD_LOGIC;								--Reset signal
				ENABLE		: IN  STD_LOGIC;								--Counter enable
				COUNT 		: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)	--Counter signal
	);
END QUADRATURE_ENCODER_COUNTER;

ARCHITECTURE BEHAVIORAL OF QUADRATURE_ENCODER_COUNTER IS

	COMPONENT QUADRATURE_DECODER
		PORT (
				CHANNEL_A : IN  STD_LOGIC;		--Channel A from the encoder
				CHANNEL_B : IN  STD_LOGIC;		--Channel B from the encoder
				CLK 		 : IN  STD_LOGIC;		--Clock signal
				x4_A_B	 : OUT STD_LOGIC;		--Signal with four times the frequency of A and B
				Direction : OUT STD_LOGIC		--Signal representing the direction of rotation
		);		
   END COMPONENT;

	COMPONENT QUADRATURE_DEBOUNCE
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
	END COMPONENT;
	
	--Signals to connect the modules for the filter phase, the decoder phase and the count phase
	SIGNAL CNT_S : UNSIGNED(N-1 DOWNTO 0);
	SIGNAL A_FILTERED_S : STD_LOGIC;
	SIGNAL B_FILTERED_S : STD_LOGIC;
	SIGNAL PULSE_X4_S : STD_LOGIC;
	SIGNAL DIRECTION_S : STD_LOGIC;

BEGIN
	-------------------------------------------------------------------------------------	
	-- DEBOUNCE THE CHANNELS A AND B FROM THE ENCODER ACCORDING TO THE DEFINED CYCLES  --
	-------------------------------------------------------------------------------------
	FILTER_PHASE : QUADRATURE_DEBOUNCE GENERIC MAP (DEBOUNCE_CYCLES) PORT MAP (CLK, CHANNEL_A, CHANNEL_B, A_FILTERED_S, B_FILTERED_S);
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------------	
	-- TAKE THE DEBOUNCE A AND B CHANNELS, MULTIPLY THE FREQUNCY AND DETERMINE THE DIRECTION --
	-------------------------------------------------------------------------------------------
	DECODER_PHASE : QUADRATURE_DECODER PORT MAP (A_FILTERED_S, B_FILTERED_S, CLK, PULSE_X4_S, DIRECTION_S);
	-------------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------	
	-- COUNT THE PULSES FROM THE ENCODER ACCORDING TO THE DIRECTION OF ROTATION 		  --
	-------------------------------------------------------------------------------------
	UP_DOWN_COUNT : PROCESS (PULSE_X4_S, DIRECTION_S, RESET)
	BEGIN
		IF RESET = '0' THEN
			CNT_S <= (OTHERS => '0');
		ELSIF RISING_EDGE(PULSE_X4_S) THEN
			IF ENABLE='1' THEN
				IF DIRECTION_S = '1' THEN
					CNT_S <= CNT_S + 1;
				ELSE
					CNT_S <= CNT_S - 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	COUNT <= STD_LOGIC_VECTOR(CNT_S);
	-------------------------------------------------------------------------------------
END BEHAVIORAL;