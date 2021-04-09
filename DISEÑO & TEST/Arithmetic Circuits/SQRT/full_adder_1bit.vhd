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
--    This block corresponds to 1 bit full adder
--    Generic n: bits numbers
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity full_adder_1bit is
port(
	a, b, cin: in std_logic;
	y, cout: out std_logic
);
end entity;

architecture rtl of full_adder_1bit is
begin

y <= a xor b xor cin;
cout <= (a and b) or (cin and (a xor b));

end rtl;