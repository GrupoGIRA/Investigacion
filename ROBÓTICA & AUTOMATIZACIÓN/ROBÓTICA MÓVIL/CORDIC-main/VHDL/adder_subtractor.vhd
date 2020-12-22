--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    add_sub ('0' -> add a+b, '1' -> subtract a-b), a (summand), b (summand)
--Outputs:
--    y (sum), cout (carry out)
--
--Description:
--    This block corresponds to the n bits adder/subtractor
--    Generic n: bits numbers
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity adder_subtractor is
generic(
	n: natural := 8
);
port(
	add_sub: in std_logic;
	a, b: in std_logic_vector(n-1 downto 0);
	y: out std_logic_vector(n-1 downto 0);
	cout: out std_logic
);
end entity;

architecture rtl of adder_subtractor is

signal b_temp: std_logic_vector(n-1 downto 0);

begin

block_xor: for i in 0 to n-1 generate
	xors: entity work.xor_gate
	port map(
		a => b(i),
		b => add_sub,
		c => b_temp(i)
	);
end generate;

adder: entity work.full_adder
generic map(
	n => n
)
port map(
	a => a,
	b => b_temp,
	cin => add_sub,
	y => y,
	cout => cout
);

end rtl;