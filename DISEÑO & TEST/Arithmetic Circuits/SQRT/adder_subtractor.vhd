--**********************************************************************************************************************
--Sqrt int Implementation
--Author: Robert Limas
--Year: 2021
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

block_xor: process(b, add_sub)
variable b_aux: std_logic_vector(n-1 downto 0);
begin
	xor_block: for i in 0 to n-1 loop
		b_aux(i) := b(i) xor add_sub;
	end loop xor_block;
	b_temp <= b_aux;
end process block_xor;

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