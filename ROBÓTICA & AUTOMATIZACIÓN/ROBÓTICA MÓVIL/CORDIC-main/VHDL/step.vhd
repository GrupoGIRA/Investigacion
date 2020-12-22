--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--Inputs:
--    x_i (required), y_i (required), z_i (required), mode (required), arctan (required)
--    *** Warning: Inputs should be in fixed point ***
--Outputs:
--    x_o (cos(z_i)), y_o (sin(z_i)), z_o(arctan2(y_i / x_i))
--    *** Warning: The results will be given at fixed point ***
--
--Description:
--    This block corresponds to one iteration of CORDIC algorithm. It is composed of 3 adders/subtractors and 2 shift
--    Generic n: bits numbers
--    Generic m: displacements numbers
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity step is
generic(
	n: natural := 8;
	m: natural := 3
);
port(
	x_i, y_i, z_i, arctan: in std_logic_vector(n-1 downto 0);
	mode: in std_logic;
	x_o, y_o, z_o: out std_logic_vector(n-1 downto 0)
);
end entity;

architecture rtl of step is

--Signals required
signal x_temp, y_temp, z_temp: std_logic_vector(n-1 downto 0);
signal x_shift, y_shift: std_logic_vector(n-1 downto 0);
signal d, d_not: std_logic;

begin

--Rotation direction multiplexer
d <= ((not mode) and z_i(n-1)) or (mode and (not y_i(n-1)));
d_not <= not d;

--Instantiation shift
shift0: entity work.shift
generic map(
	n => n,
	m => m
)
port map(
	a => x_i,
	y_right => x_shift
);

shift1: entity work.shift
generic map(
	n => n,
	m => m
)
port map(
	a => y_i,
	y_right => y_shift
);

--Instantiation adders/subtractors
adder0: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	a => x_i,
	b => y_shift,
	add_sub => d_not,
	y => x_temp
);

adder1: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	a => y_i,
	b => x_shift,
	add_sub => d,
	y => y_temp
);

adder2: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	a => z_i,
	b => arctan,
	add_sub => d_not,
	y => z_temp
);

--Outpus assignment
x_o <= x_temp;
y_o <= y_temp;
z_o <= z_temp;

end rtl;