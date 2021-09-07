--**********************************************************************************************************************
--Sqrt int implementation
--Authors:
--  Robert Alexander Limas S
--  Wilson Javier Perez H
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
	n: natural := 16
);
end entity;

architecture rtl of tb is

signal radicand: std_logic_vector(n-1 downto 0);
signal root: std_logic_vector(n-1 downto 0);
signal remainder: std_logic_vector(n-1 downto 0);
signal radicand_temp: signed(n-1 downto 0) := (others=>'0');

file data_root_int: text open WRITE_MODE is "../VHDL/root_int.txt";
file data_root_decimal: text open WRITE_MODE is "../VHDL/root_decimal.txt";

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

--Create simulations files
process
	variable line_root_int, line_root_decimal: line;
	variable data_root_int_i, data_root_decimal_i: integer;
	variable root_int_v, root_decimal_v: std_logic_vector(n-1 downto 0);
	variable count: integer;
begin
	count := 0;
	wait for 600 ns;
	while (count<200) loop
		radicand_temp <= radicand_temp + 1;
		wait for 100 ns;
		--Write root int
		data_root_int_i := to_integer(signed(root));
		write(line_root_int, data_root_int_i);
		writeLine(data_root_int, line_root_int);
		
		--Write root decimal
		data_root_decimal_i := to_integer(signed(remainder));
		write(line_root_decimal, data_root_decimal_i);
		writeLine(data_root_decimal, line_root_decimal);
		count := count + 1;
	end loop;
end process;

end rtl;
