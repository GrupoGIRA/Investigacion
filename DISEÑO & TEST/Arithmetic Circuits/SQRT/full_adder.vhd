--**********************************************************************************************************************
--Sqrt int Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    a (summand), b (summand), cin (carry in)
--Outputs:
--    y (sum), cout (carry out)
--
--Description:
--    This block corresponds to n bits full adder
--    Generic n: bits numbers
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
generic(
	n: natural := 8
);
port(
	cin: in std_logic;
	a, b: in std_logic_vector(n-1 downto 0);
	y: out std_logic_vector(n-1 downto 0);
	cout: out std_logic
);
end entity;

architecture rtl of full_adder is

signal c: std_logic_vector(n downto 0);

begin

c(0) <= cin;

adder: for i in 0 to n-1 generate
	adder_1bit: entity work.full_adder_1bit
	port map(
		a => a(i),
		b => b(i),
		cin => c(i),
		y => y(i),
		cout => c(i+1)
	);
end generate;

cout <= c(n);

end rtl;