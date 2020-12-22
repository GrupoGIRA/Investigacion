--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    a
--Outputs:
--    y
--
--Description:
--    This block corresponds to d register
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity registers is
generic(
	n: natural := 8
);
port(
	clk, enable, rst: in std_logic;
	a: in std_logic_vector(n-1 downto 0);
	y: out std_logic_vector(n-1 downto 0)
);
end entity;

architecture rtl of registers is

begin

process(clk, rst, enable)
begin
if rst = '0' then
	y <= (others=>'0');
elsif rising_edge(clk) and enable = '1' then
	y <= a;
end if;
end process;

end rtl;