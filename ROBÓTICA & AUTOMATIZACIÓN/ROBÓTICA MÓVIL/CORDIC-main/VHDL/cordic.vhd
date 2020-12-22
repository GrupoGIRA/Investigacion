--**********************************************************************************************************************
--Stream Processing CORDIC Algorithm Implementation
--Author: Robert Limas
--Year: 2020
--Research Group GIRA
--Universidad Pedagogica y Tecnologica de Colombia
--
--TOP LEVEL
--
--Inputs:
--    x_i (required), y_i (required), z_i (required), mode (required), enable (required)
--    *** Warning: Inputs should be in fixed point ***
--Outputs:
--    x_o (cos(z_i)), y_o (sin(z_i)), z_o(arctan2(y_i / x_i))
--    *** Warning: The results will be given at fixed point ***
--
--Description:
--This algorithm works between pi/2 and -pi/2
--This implementation uses fixed point with decimal resolution 14 bits, integer resolution 14 bits and 16 iterations
--It uses (iterations + 2) clock clycles to deliver the result
--It has two operation mode
--
--1. Rotation -> mode = 0
--    Mode used for calculate sin and cos functions
--    *** Warning: Inputs x and y should be equal to 0 and input z should be has the angle in rad***
--2. Vectoring -> mode = 1
--    Mode used for calculate arctan2(y_i / x_i) function
--    *** Warning: Input z should be equal to 0 ***
--**********************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is
generic(
	n: natural := 28;
	iterations: natural := 16
);
port(
	x_i, y_i, z_i: in std_logic_vector(n-1 downto 0);
	mode, clk, rst, enable: in std_logic;
	x_o, y_o, z_o: out std_logic_vector(n-1 downto 0);
	mode_o, enable_o: out std_logic
);
end entity;

architecture rtl of cordic is

--Signals pipeline
signal x_i_t, y_i_t, z_i_t: std_logic_vector(n-1 downto 0);
signal x_o_t, y_o_t, z_o_t: std_logic_vector(n-1 downto 0);

type data is array (0 to iterations-1) of std_logic_vector(n-1 downto 0);
signal xi_temp, yi_temp, zi_temp: data;
signal xo_temp, yo_temp, zo_temp: data;

signal mode_temp, enable_temp: std_logic_vector(iterations+1 downto 0);
signal x_temp: std_logic_vector(n-1 downto 0);

--Constant values arcotangent table
type data_arctan is array (0 to iterations-1) of std_logic_vector(n-1 downto 0);
signal arctan: data_arctan := (
	std_logic_vector(to_signed(12_867, n)), std_logic_vector(to_signed(7_596, n)), 
	std_logic_vector(to_signed(4_013, n)), std_logic_vector(to_signed(2_037, n)), 
	std_logic_vector(to_signed(1_022, n)), std_logic_vector(to_signed(511, n)), 
	std_logic_vector(to_signed(255, n)), std_logic_vector(to_signed(127, n)), 
	std_logic_vector(to_signed(63, n)), std_logic_vector(to_signed(31, n)), 
	std_logic_vector(to_signed(15, n)), std_logic_vector(to_signed(7, n)), 
	std_logic_vector(to_signed(3, n)), std_logic_vector(to_signed(1, n)), 
	std_logic_vector(to_signed(0, n)), std_logic_vector(to_signed(0, n))
);

begin

--Registers pipeline inputs and outputs
inputs_outputs: process(clk, rst)
begin
if rst = '0' then
	x_i_t <= (others=>'0');
	y_i_t <= (others=>'0');
	z_i_t <= (others=>'0');
	x_o_t <= (others=>'0');
	y_o_t <= (others=>'0');
	z_o_t <= (others=>'0');
elsif rising_edge(clk) then
	x_i_t <= x_i;
	y_i_t <= y_i;
	z_i_t <= z_i;
	x_o_t <= xo_temp(iterations-1);
	y_o_t <= yo_temp(iterations-1);
	z_o_t <= zo_temp(iterations-1);
end if;
end process inputs_outputs;

--Registers pipeline enable and mode
enable_mode: process(clk, rst)
begin
if rst = '0' then
	mode_temp <= (others=>'0');
	enable_temp <= (others=>'0');
elsif rising_edge(clk) then
	mode_temp(0) <= mode;
	mode_temp(iterations+1 downto 1) <= mode_temp(iterations downto 0);
	enable_temp(0) <= enable;
	enable_temp(iterations+1 downto 1) <= enable_temp(iterations downto 0);
end if;
end process enable_mode;

--Scale factor (1 / 1.6468) * 2**14 = 9.949
x_temp <= std_logic_vector(to_signed(9_949, n)) when mode_temp(0) = '0' else x_i_t;

--Generic implementation
iteration: for i in 0 to iterations-1 generate
	steps: entity work.step
	generic map(
		n => n,
		m => i
	)
	port map(
		x_i => xi_temp(i),
		y_i => yi_temp(i),
		z_i => zi_temp(i),
		arctan => arctan(i),
		mode => mode_temp(i+1),
		x_o => xo_temp(i),
		y_o => yo_temp(i),
		z_o => zo_temp(i)
	);
	initialize:  if (i = 0) generate
		reg_x: entity work.registers
		generic map(
			n => n
		)
		port map(
			clk => clk,
			enable => enable,
			rst => rst,
			a => x_temp,
			y => xi_temp(i)
		);
		reg_y: entity work.registers
		generic map(
			n => n
		)
		port map(
			clk => clk,
			enable => enable,
			rst => rst,
			a => y_i_t,
			y => yi_temp(i)
		);
		reg_z: entity work.registers
		generic map(
			n => n
		)
		port map(
			clk => clk,
			enable => enable,
			rst => rst,
			a => z_i_t,
			y => zi_temp(i)
		);
	end generate initialize;
	continue:  if (i > 0) generate
		reg_x: entity work.registers
		generic map(
			n => n
		)
		port map(
			clk => clk,
			enable => enable,
			rst => rst,
			a => xo_temp(i-1),
			y => xi_temp(i)
		);
		reg_y: entity work.registers
		generic map(
			n => n
		)
		port map(
			clk => clk,
			enable => enable,
			rst => rst,
			a => yo_temp(i-1),
			y => yi_temp(i)
		);
		reg_z: entity work.registers
		generic map(
			n => n
		)
		port map(
			clk => clk,
			enable => enable,
			rst => rst,
			a => zo_temp(i-1),
			y => zi_temp(i)
		);
	end generate continue;
end generate iteration;

--Outpus assignment
x_o <= x_o_t;
y_o <= y_o_t;
z_o <= z_o_t;
mode_o <= mode_temp(iterations+1);
enable_o <= enable_temp(iterations+1);

end rtl;