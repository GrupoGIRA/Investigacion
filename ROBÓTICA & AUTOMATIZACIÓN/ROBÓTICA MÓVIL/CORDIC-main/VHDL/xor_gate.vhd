--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    a, b
--Outputs:
--    c
--
--Description:
--    This block corresponds to xor implementation
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity xor_gate is
port(
	a, b: in std_logic;
	c: out std_logic
);
end entity;

architecture rtl of xor_gate is

begin

c <= a xor b;

end rtl;