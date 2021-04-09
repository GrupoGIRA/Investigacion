--**********************************************************************************************************************
--Sqrt int implementation
--Author: Robert Limas
--Year: 2021
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Test bench file
--
--Description:
--This file is to verify the correct operation of the implementation.
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
generic(
	n: natural := 6
);
end entity;

architecture rtl of tb is

signal radicand: std_logic_vector(n-1 downto 0);
signal root: std_logic_vector((n/2)-1 downto 0);
signal remainder: std_logic_vector(n+(n/2)-1 downto 0);
signal radicand_temp: signed(n-1 downto 0) := (others=>'0');

begin

radicand <= std_logic_vector(radicand_temp);

--Design instantiation
sqrt0: entity work.sqrt
generic map(
	n => n
)
port map(
	radicand => radicand,
	root_int => root,
	root_decimal => remainder
);

--Counter for divisor test
process
begin
radicand_temp <= radicand_temp + 1;
wait for 150 ns;
end process;

end rtl;