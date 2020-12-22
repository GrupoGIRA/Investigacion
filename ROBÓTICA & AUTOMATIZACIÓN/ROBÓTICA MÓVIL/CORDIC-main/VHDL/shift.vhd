--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    a (required)
--Outputs:
--    y_left (a with m displacements to left), y_right  (a with m displacements to right)
--
--Description:
--    This block corresponds to the divisions for each iteration
--    Generic n: bits numbers
--    Generic m: displacements numbers
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift is
generic(
	n: natural := 8;
	m: natural := 3
);
port(
	a: in std_logic_vector(n-1 downto 0);
	y_left, y_right: out std_logic_vector(n-1 downto 0)
);
end entity;

architecture rtl of shift is
begin

y_left <= std_logic_vector(shift_left(signed(a), m));
y_right <= std_logic_vector(shift_right(signed(a), m));

end rtl;