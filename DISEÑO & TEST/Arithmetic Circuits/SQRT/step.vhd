--**********************************************************************************************************************
--Sqrt int implementation
--Author: Robert Limas
--Year: 2021
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    remainder_before, root_before
--Outputs:
--    root, remainder
--
--Description:
--    This block corresponds to one step of the square root algorithm
--    Generic n: bits numbers
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity step is
generic(
	n: natural := 8
);
port(
	remainder_before, root_before: in std_logic_vector(n-1 downto 0);
	remainder: out std_logic_vector(n-1 downto 0);
	root: out std_logic
);
end entity;

architecture rtl of step is

--signals
signal remainder_shift, subtract: std_logic_vector(n-1 downto 0);

begin

--the fisrt step is to multiply the remainder by 2, this is equivalent to 1 left shift
remainder_shift <= remainder_before(n-2 downto 0) & '0';

--the second step is to subtract the remainder * 2 and the before value
subtractor: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	add_sub => '1',
	a => remainder_shift,
	b => root_before,
	y => subtract
);

--if remainder is positive, this value is the output, else the output is the remainder original * 2
remainder <= subtract when subtract(n-1) = '0' else remainder_shift;
--if remainder is positive, the root bit is 1, else is 0
root <= not subtract(n-1);

end rtl;