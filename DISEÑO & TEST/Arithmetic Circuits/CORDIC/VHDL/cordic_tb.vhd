--*************************************************************************************************
--	Stream Processing CORDIC Algorithm Implementation
--	Authors:
--    Robert Alexander Limas
--    Wilson Javier Perez Holguin
--
--	GIRA Research Group
--	Universidad Pedagogica y Tecnologica de Colombia
--
--	Test bench file
--
--	Description:
--		Testbench file to verify the correct operation of the cordic algorithm implementation.
--		Thsi file uses txt files as input and generate txt files as output.
--  Year: 2020
--*************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity cordic_tb is
	generic(n: natural := 16);
end entity;

architecture rtl of cordic_tb is

	-- Accesing Files in Read Mode 
	file data_x_input: text open READ_MODE is "./input/input_x.txt";
	file data_y_input: text open READ_MODE is "./input/input_y.txt";
	file data_z_input: text open READ_MODE is "./input/input_z.txt";
	file data_mode_input: text open READ_MODE is "./input/input_mode.txt";
	file data_enable_input: text open READ_MODE is "./input/input_enable.txt";
	file data_coord_input: text open READ_MODE is "./input/input_coord.txt";
	-- Accesing Files in Write Mode
	file data_x_output: text open WRITE_MODE is "./output/output_x_vhdl.txt";
	file data_y_output: text open WRITE_MODE is "./output/output_y_vhdl.txt";
	file data_z_output: text open WRITE_MODE is "./output/output_z_vhdl.txt";
	file data_mode_output: text open WRITE_MODE is "./output/output_mode_vhdl.txt";
	file data_enable_output: text open WRITE_MODE is "./output/output_enable_vhdl.txt";
	file data_coord_output: text open WRITE_MODE is "./output/output_coord_vhdl.txt";
	-- Declearing signals
	signal x_i, y_i, z_i: std_logic_vector(n-1 downto 0) := (others=>'0');
	signal x_o, y_o, z_o: std_logic_vector(n-1 downto 0);
	signal enable_i, enable_o, clk, rst, mode_i, mode_o, coord_i, coord_o: std_logic := '0';

begin

	--Design instantiation
	cordic0: entity work.cordic
	port map(
		x_i => x_i,
		y_i => y_i,
		z_i => z_i,
		mode => mode_i,
		coord_sys => coord_i,
		clk => clk,
		rst => rst,
		enable => enable_i,
		x_o => x_o,
		y_o => y_o,
		z_o => z_o,
		mode_o => mode_o,
		enable_o => enable_o,
		coord_out => coord_o
	);

	--Clock signal generation
	process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;

	--Reset signal generation
	process
	begin
		rst <= '0';
		wait for 500 ns;
		rst <= '1';
		wait;
	end process;

	--Reading files
	process
	
		variable line_x_input, line_y_input, line_z_input, line_coord_input: line;
		variable line_x_output, line_y_output, line_z_output, line_coord_output: line;
		variable line_enable_input, line_mode_input: line;
		variable line_enable_output, line_mode_output: line;
		variable data_x_i, data_y_i, data_z_i, data_coord_i: integer;
		variable data_x_o, data_y_o, data_z_o, data_coord_o: integer;
		variable data_enable_i, data_mode_i: integer;
		variable data_enable_o, data_mode_o: integer;
		variable enable, mode, coord: std_logic_vector(0 downto 0);
	
	begin
	
		wait for 600 ns;
		wait until falling_edge(clk);
		while not endfile (data_x_input) loop
			--X data reading
			readLine(data_x_input, line_x_input);
			read(line_x_input, data_x_i);
			x_i <= std_logic_vector(to_signed(data_x_i, n));
			
			--Y data reading
			readLine(data_y_input, line_y_input);
			read(line_y_input, data_y_i);
			y_i <= std_logic_vector(to_signed(data_y_i, n));
			
			--Z data reading
			readLine(data_z_input, line_z_input);
			read(line_z_input, data_z_i);
			z_i <= std_logic_vector(to_signed(data_z_i, n));
			
			--Enable data reading
			readLine(data_enable_input, line_enable_input);
			read(line_enable_input, data_enable_i);
			enable := std_logic_vector(to_unsigned(data_enable_i, 1));
			enable_i <= enable(0);
			
			--Mode data reading
			readLine(data_mode_input, line_mode_input);
			read(line_mode_input, data_mode_i);
			mode := std_logic_vector(to_unsigned(data_mode_i, 1));
			mode_i <= mode(0);

			--Coordinate system data reading
			readLine(data_coord_input, line_coord_input);
			read(line_coord_input, data_coord_i);
			coord := std_logic_vector(to_unsigned(data_coord_i, 1));
			coord_i <= coord(0);
			
			wait until falling_edge(clk);
			
			--X data writing
			data_x_o := to_integer(signed(x_o));
			write(line_x_output, data_x_o);
			writeLine(data_x_output, line_x_output);
			
			--Y data writing
			data_y_o := to_integer(signed(y_o));
			write(line_y_output, data_y_o);
			writeLine(data_y_output, line_y_output);
			
			--Z data writing
			data_z_o := to_integer(signed(z_o));
			write(line_z_output, data_z_o);
			writeLine(data_z_output, line_z_output);
			
			--Enable data writing
			enable(0) := enable_o;
			data_enable_o := to_integer(unsigned(enable));
			write(line_enable_output, data_enable_o);
			writeLine(data_enable_output, line_enable_output);
			
			--Mode data writing
			mode(0) := mode_o;
			data_mode_o := to_integer(unsigned(mode));
			write(line_mode_output, data_mode_o);
			writeLine(data_mode_output, line_mode_output);

			--Coordinate system data writing
			coord(0) := coord_o;
			data_coord_o := to_integer(unsigned(coord));
			write(line_coord_output, data_coord_o);
			writeLine(data_coord_output, line_coord_output);		
		end loop;
		wait;
	end process;
	
end rtl;