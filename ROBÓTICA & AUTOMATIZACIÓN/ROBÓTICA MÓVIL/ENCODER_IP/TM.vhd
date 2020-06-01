-- WILSON JAVIER PEREZ HOLGUIN
-- SAMPLE PULSE GENERATOR
-- 26/04/2020

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TM IS

    GENERIC
    (
        CLK_FREQ : NATURAL := 50_000_000;       -- 50 MHZ
        TM_S : NATURAL := 2                     -- TM SELECTION (IN MILISECONDS)
    );

    PORT
    (
        CLK     : IN STD_LOGIC;
        TM_O    : OUT STD_LOGIC
    );

END ENTITY;

ARCHITECTURE RTL OF TM IS
BEGIN

    -- SAMPLE PULSE GENERATOR
    DIV : PROCESS (CLK)
        VARIABLE  TMP : INTEGER RANGE 0 TO CLK_FREQ := 0;
    BEGIN
        IF (RISING_EDGE(CLK)) THEN
            IF TMP < (TM_S*CLK_FREQ/1_000) THEN
                TM_O <= '0';
                TMP := TMP + 1;
            ELSE
                TM_O <= '1';
                TMP := 0;
            END IF;
        END IF;
    END PROCESS;
END RTL;

