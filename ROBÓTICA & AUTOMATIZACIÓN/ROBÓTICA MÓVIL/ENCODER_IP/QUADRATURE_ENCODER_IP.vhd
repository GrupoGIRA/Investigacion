--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--																																		--
--		Authors				:  Andres-David Suarez-Gomez and Wilson-Javier Perez Holguín  						--
--		Institution			:	Universidad Pedagogica y Tecnologica de Colombia (UPTC)							--
--		Entity				:	Grupo de Investigacion en Robotica y Automatizacion Industrial (GIRA)		--
--																																		--
--		FileName				:	QUADRATURE_ENCODER_IP.vhd																	--
--		Design Software 	:  Quartus II 64-bit Version 13.1.4 Build 182 03/12/2014 SJ Web Edition			--
--																																		--
--		Description 		:	Used for a Custom IP in Qsys that takes as input the A and B channels of	--
--									four quadrature encoders and outputs four counters with the pulse				--
--									according to the direction of rotation. It has two operation modes: 			--
--									(i) Reset on read mode, in which each time there is a read from Qsys there	--
--									is a reset in the counters. To use this mode set RESET_ON_READ to 1.			--
--									(ii) Timer mode, in which there is a timer with period TM_S in ms. When    --
--									this time is reached, the IP outputs the counter values, activates an 		--
--									interrupt signal for the processor and resets the counters. To use this		--
--									mode ser RESET_ON_READ to 0.																--
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

ENTITY QUADRATURE_ENCODER_IP IS
	GENERIC (        
				CLK_FREQ 			: NATURAL 	:= 2_000;	-- Clock frecuency comming from Qsys
				TM_S 					: NATURAL 	:= 20;		-- Timer selection (in miliseconds)
				RESET_ON_READ 		: NATURAL 	:= 1;		-- 1 for reset on read, 0 to generate an interrupt according to the Tm signal						
				N 						: POSITIVE 	:= 8;			-- Number of bits of the counter for the encoder pulses
				DEBOUNCE_CYCLES 	: POSITIVE 	:= 1			-- Number of cycles to debounce from the encoder channels (DEBOUNCE_CYCLES + 2)
	);
	 
	PORT(
				CLOCK 			: IN  STD_LOGIC;										--Clock signal from Qsys
				RESETN 			: IN  STD_LOGIC;										--Reset_n signal from Qsys
				READ_N  			: IN  STD_LOGIC;										--Read_n signal from Qsys (0 for the read proccess)
				ENCODER_INPUT 	: IN  STD_LOGIC_VECTOR( 7 DOWNTO 0);			--Inputs for four quadrature encoders
				READDATA 		: OUT STD_LOGIC_VECTOR(((4*N)-1) DOWNTO 0);	--Data read from Qsys with four encoder pulse counters
				INT_SENDER 		: OUT STD_LOGIC										--Signal to activate an interrupt in the processor for the timer
	);
END QUADRATURE_ENCODER_IP;

ARCHITECTURE BEHAVIORAL OF QUADRATURE_ENCODER_IP IS
	
	COMPONENT QUADRATURE_ENCODER_COUNTER
		GENERIC (
					N 						: POSITIVE := 8;	-- Number of bits of the counter for the encoder pulses
					DEBOUNCE_CYCLES 	: POSITIVE := 5	-- Number of cycles to debounce from the encoder channels (DEBOUNCE_CYCLES + 2)
		);
		PORT (
					CHANNEL_A 	: IN  STD_LOGIC;								--Channel A from the encoder
					CHANNEL_B 	: IN  STD_LOGIC;								--Channel B from the encoder
					CLK 			: IN  STD_LOGIC;								--Clock signal
					RESET 		: IN  STD_LOGIC;								--Reset signal
					ENABLE		: IN  STD_LOGIC;								--Counter enable
					COUNT 		: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)	--Counter signal
		);
	END COMPONENT;
	 
	COMPONENT TM
		GENERIC (
					CLK_FREQ : NATURAL := 50_000_000;  -- 50 MHZ
					TM_S 		: NATURAL := 2            -- Timer selection (in miliseconds)
		);
		PORT (
				CLK	: IN  STD_LOGIC;	--Clock signal
				TM_O  : OUT STD_LOGIC	--Signal set to one when the timer reaches TM_S ms
		);
	END COMPONENT;
	
	--Signals for the A and B channels of the encoders
	SIGNAL ENCODER_L_1_A 		: STD_LOGIC;
	SIGNAL ENCODER_L_1_B 		: STD_LOGIC;
	SIGNAL ENCODER_L_2_A 		: STD_LOGIC;
	SIGNAL ENCODER_L_2_B 		: STD_LOGIC;
	SIGNAL ENCODER_R_1_A 		: STD_LOGIC;
	SIGNAL ENCODER_R_1_B 		: STD_LOGIC;
	SIGNAL ENCODER_R_2_A 		: STD_LOGIC;
	SIGNAL ENCODER_R_2_B 		: STD_LOGIC;
	
	--Signals for the encoder counters
	SIGNAL ENCODER_L_1_COUNT 	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL ENCODER_L_2_COUNT 	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL ENCODER_R_1_COUNT 	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL ENCODER_R_2_COUNT 	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	
	--Signal that is set to 1 (for one clock cycle) when the timer period is reached
	SIGNAL TM_PERIOD 				: STD_LOGIC;
	
	-- Signal to reset the encoder counters 
	SIGNAL RESET_COUNTER 		: STD_LOGIC := '1';
	
	--Signal for the FSM
	TYPE STATE IS (S0, S1);
   SIGNAL CURRENT_STATE : STATE := S0; 
	SIGNAL NEXT_STATE : STATE;
	SIGNAL sREAD_N : STD_LOGIC;
	
BEGIN

	-------------------------------------------------------------------------------------	
	-- ASSIGN EACH BIT FROM THE ENCODER INPUT TO THE CORRESPONDING ENCODER AND CHANNEL --
	-------------------------------------------------------------------------------------
	ENCODER_L_1_A <= ENCODER_INPUT (7);
	ENCODER_L_1_B <= ENCODER_INPUT (6);
	ENCODER_L_2_A <= ENCODER_INPUT (5);
	ENCODER_L_2_B <= ENCODER_INPUT (4);
	ENCODER_R_1_A <= ENCODER_INPUT (3);
	ENCODER_R_1_B <= ENCODER_INPUT (2);
	ENCODER_R_2_A <= ENCODER_INPUT (1);
	ENCODER_R_2_B <= ENCODER_INPUT (0);
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------	
	-- GENERATE THE TIMER SIGNAL ACCORDING TO THE CLOCK FREQUENCY AND TIME SELECTED    --
	-------------------------------------------------------------------------------------
	PERIOD : TM GENERIC MAP (CLK_FREQ, TM_S) PORT MAP (CLOCK, TM_PERIOD);
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------
	-- DEBOUNCE THE A AND B CHANNELS FROM THE ENCODERS AND COUNT THE PULSES FROM THEM  --
	-------------------------------------------------------------------------------------
	ENCODER_L_1 : QUADRATURE_ENCODER_COUNTER GENERIC MAP (N, DEBOUNCE_CYCLES) PORT MAP (ENCODER_L_1_A, ENCODER_L_1_B, CLOCK, RESET_COUNTER, '1', ENCODER_L_1_COUNT);
	ENCODER_L_2 : QUADRATURE_ENCODER_COUNTER GENERIC MAP (N, DEBOUNCE_CYCLES) PORT MAP (ENCODER_L_2_A, ENCODER_L_2_B, CLOCK, RESET_COUNTER, '1', ENCODER_L_2_COUNT);
	ENCODER_R_1 : QUADRATURE_ENCODER_COUNTER GENERIC MAP (N, DEBOUNCE_CYCLES) PORT MAP (ENCODER_R_1_A, ENCODER_R_1_B, CLOCK, RESET_COUNTER, '1', ENCODER_R_1_COUNT);
	ENCODER_R_2 : QUADRATURE_ENCODER_COUNTER GENERIC MAP (N, DEBOUNCE_CYCLES) PORT MAP (ENCODER_R_2_A, ENCODER_R_2_B, CLOCK, RESET_COUNTER, '1', ENCODER_R_2_COUNT);
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------	
	-- FSM TO ENSURE A PULSE WIDTH OF ONLY 1 CLOCK PULSE FOR THE READ_N SIGNAL			  --
	-------------------------------------------------------------------------------------
	NSL : PROCESS(CURRENT_STATE, READ_N)
   BEGIN 
		CASE CURRENT_STATE IS 
			WHEN S0 =>
				IF READ_N = '1' THEN
					NEXT_STATE <= S0;
					sREAD_N <= '0';
				ELSIF READ_N = '0' THEN
					NEXT_STATE <= S1;
					sREAD_N <= '1';
				ELSE
					NEXT_STATE <= S0;
					sREAD_N <= '0';
				END IF;
			WHEN S1 =>
				IF READ_N = '1' THEN
					NEXT_STATE <= S0;
					sREAD_N <= '0';	
				ELSIF READ_N = '0' THEN
					NEXT_STATE <= S1;
					sREAD_N <= '0';
				ELSE
					NEXT_STATE <= S0;
					sREAD_N <= '0';
				END IF;	
			WHEN OTHERS =>
				NEXT_STATE <= S0;
				sREAD_N <= '0';	
		END CASE;
		
	END PROCESS;
   REG_STATE : PROCESS(CLOCK)
   BEGIN
		IF (RISING_EDGE(CLOCK)) THEN
        CURRENT_STATE <= NEXT_STATE;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------------
	
	-------------------------------------------------------------------------------------
	-- OUTPUT THE INTERRUPT AND COUNTERS DATA ACCORDING TO THE MODE OF OPERATION		  --
	-------------------------------------------------------------------------------------
	PROCESS (CLOCK, TM_PERIOD, sREAD_N, RESETN)
	BEGIN
		IF (RESETN = '0') THEN
			READDATA <= (OTHERS=>'0');
		ELSIF (RISING_EDGE(CLOCK)) THEN 
			IF (RESET_ON_READ = 0) THEN
				IF (TM_PERIOD = '1') THEN 
					READDATA <= ENCODER_L_1_COUNT & ENCODER_L_2_COUNT & ENCODER_R_1_COUNT & ENCODER_R_2_COUNT;
					RESET_COUNTER <= '0';
					INT_SENDER <= '1';
				ELSE
					RESET_COUNTER <= '1';
					INT_SENDER <= '0';
				END IF;
			ELSIF (RESET_ON_READ = 1) THEN 
				IF (sREAD_N = '1') THEN
					READDATA <= ENCODER_L_1_COUNT & ENCODER_L_2_COUNT & ENCODER_R_1_COUNT & ENCODER_R_2_COUNT;
					RESET_COUNTER <= '0';
				ELSE
					RESET_COUNTER <= '1';
				END IF;
				INT_SENDER <= '0';
			END IF;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------------

END BEHAVIORAL;