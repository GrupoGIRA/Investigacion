--**********************************************************************************************************************
--Sqrt int implementation
--Author: Robert Limas
--Year: 2021
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    radicand, remainder_before
--Outputs:
--    root_int, root_decimal
--
--Description:
--    This block corresponds to square root algorithm
--    Generic n: bits numbers and must be even
--    This algorithm is based:
--        Israel Koren. Computer Algorithms. 2nd Edition. AK Peters Ltd. 2002
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity sqrt is
generic(
	n: natural := 8
);
port(
	radicand: in std_logic_vector(n-1 downto 0);
	root_int: out std_logic_vector((n/2)-1 downto 0);
	root_decimal: out std_logic_vector(n+(n/2)-1 downto 0)
);
end entity;

architecture rtl of sqrt is

--signals
type arrayN1 is array (0 to n) of std_logic_vector((2*n)-1 downto 0);
signal remainderArray: arrayN1;

type arrayN is array (0 to n-1) of std_logic_vector((2*n)-1 downto 0);
signal rootArray, valueAux, valueRoot: arrayN;

signal zeros, rootSignal: std_logic_vector(n-1 downto 0);

begin

--the radicand is assigned to a signal with size of 2*n bits to avoid overflow
zeros <= (others=>'0');
remainderArray(0) <= zeros & radicand;

--this process assigns the value 2^-1, 2^-2, ...
valuesAux: process(valueAux)
variable aux: arrayN;
begin
aux(0) := (n-1=>'1', others=>'0');
for i in 1 to n-1 loop
	aux(i) :=  '0' & aux(i-1)((2*n)-1 downto 1);
end loop;
valueAux <= aux;
end process valuesAux;

--this process assigns the value 2 * before radicand
--the first before radicand is zero
valuesRoot: process(valueRoot, rootSignal)
variable aux: arrayN;
begin
aux(0) := (others=>'0');
for i in 1 to n-1 loop
	aux(i) := aux(i-1)((2*n)-1 downto n-i+2) & rootSignal(n-i) & aux(i-1)(n-i downto 0);
end loop;
valueRoot <= aux;
end process valuesRoot;

--instantation blocks
steps_instantation: for i in 0 to n-1 generate
	steps: entity work.step
	generic map(
		n => 2*n
	)
	port map(
		remainder_before => remainderArray(i),
		root_before => rootArray(i),
		remainder => remainderArray(i+1),
		root => rootSignal(n-i-1)
	);
	--this adder is for 2 * before radicand add 2^-i+1
	adders: entity work.full_adder
	generic map(
		n => 2*n
	)
	port map(
		cin => '0',
		a => valueRoot(i),
		b => valueAux(i),
		y => rootArray(i)
);
end generate steps_instantation;

--output assigns
root_int <= rootSignal(n-1 downto (n/2));
root_decimal <= rootSignal((n/2)-1 downto 0) & remainderArray(n)(n-1 downto 0);

end rtl;