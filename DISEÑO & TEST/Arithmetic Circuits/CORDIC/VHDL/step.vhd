--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Authors:
--  Robert Limas
--  Wilson Perez
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
	x_i, y_i, z_i, arctan, arctanh: in std_logic_vector(n-1 downto 0);
	mode, coor: in std_logic;
	x_o, y_o, z_o: out std_logic_vector(n-1 downto 0)
);
end entity;

architecture rtl of step is

--Signals required
signal x_temp, y_temp, z_temp, f: std_logic_vector(n-1 downto 0);
signal x_shift0, x_shift1, y_shift0, y_shift1: std_logic_vector(n-1 downto 0);
signal d, d_not, u: std_logic;
signal aux_shift_x, aux_shift_y: std_logic_vector(n-1 downto 0);

begin

--Rotation direction multiplexer
--Select rotation or vectoring mode
d <= ((not mode) and z_i(n-1)) or (mode and (not y_i(n-1)));
d_not <= not d;
--When coor is circular '0'
--if d is 1, adder/sub its configurate in sub
--if d is -1, adder/sub its configurate in adder
--When coor is hyperbolic '1'
--if d is 1, adder/sub its configurate in adder
--if d is -1, adder/sub its configurate in sub
u <= d xnor coor;

--Selection in ArcTan o ArcTanH values for the coordinate system
f <= arctan when coor = '0' else arctanh;

--Instantiation shift
shift0: entity work.shift
generic map(
	n => n,
	m => m
)
port map(
	a => x_i,
	y_right => x_shift0
);

shift2: entity work.shift
generic map(
	n => n,
	m => m
)
port map(
	a => y_i,
	y_right => y_shift0
);

shift_conditional_start: if (m < 4) generate
	shift1: entity work.shift
	generic map(
		n => n,
		m => m + 1
	)
	port map(
		a => x_i,
		y_right => x_shift1
	);
	shift3: entity work.shift
	generic map(
		n => n,
		m => m + 1
	)
	port map(
		a => y_i,
		y_right => y_shift1
	);
end generate shift_conditional_start;

shift_conditional_end: if (m > 3) generate
	shift1: entity work.shift
	generic map(
		n => n,
		m => m
	)
	port map(
		a => x_i,
		y_right => x_shift1
	);
	shift3: entity work.shift
	generic map(
		n => n,
		m => m
	)
	port map(
		a => y_i,
		y_right => y_shift1
	);
end generate shift_conditional_end;

aux_shift_x <= x_shift0 when coor = '0' else x_shift1;
aux_shift_y <= y_shift0 when coor = '0' else y_shift1;

--Instantiation adders/subtractors
adder0: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	a => x_i,
	b => aux_shift_y,
	add_sub => u,
	y => x_temp
);

adder1: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	a => y_i,
	b => aux_shift_x,
	add_sub => d,
	y => y_temp
);

adder2: entity work.adder_subtractor
generic map(
	n => n
)
port map(
	a => z_i,
	b => f,
	add_sub => d_not,
	y => z_temp
);

--Outpus assignment
x_o <= x_temp;
y_o <= y_temp;
z_o <= z_temp;

end rtl;