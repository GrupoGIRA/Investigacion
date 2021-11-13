"""
CORDIC Algorithm implementation
Authors:
--  Robert Alexander Limas Sierra
--  Wilson Javier Perez Holguin
Year: 2020
"""
import os
import matplotlib.pyplot as plt
import numpy as np
from utils import decoding, coding, deg_to_rad, get_fullpath, read_file, rad_to_deg, relative_error, write_file


def create_files_to_simulate(resolution=14):
    angles = np.arange(-89, 89, 1)
    path_input = os.path.abspath(__file__)
    path_dir, _ = os.path.split(path_input)
    path_input_dir = os.path.join(path_dir, 'input')
    inputs_files = [
        'input_x.txt',
        'input_y.txt',
        'input_z.txt',
        'input_mode.txt',
        'input_coor.txt',
        'input_enable.txt'
    ]
    path_inputs = []
    for file in inputs_files:
        path_inputs.append(os.path.join(path_input_dir, file))
    axes_circular, axes_hyperbolic, axes_arctanh = [], [], []
    x, y, z = [], [], [] # Values to simulate the module
    enable, mode, coord = [], [], [] # Values to simulate the module
    sin, cos, arctan = [], [], [] # Values to compare
    sinh, cosh, arctanh = [], [], [] # Values to compare
    for angle in angles:
        angle_rad = deg_to_rad(angle)
        angle_fixed = coding(angle_rad, resolution)
        axes_circular.append(angle)
        # Enable
        enable.append(1)
        # --- Circular coordinate system
        # Adding data for vectoring mode
        x.append(coding(np.cos(angle_rad), resolution))
        y.append(coding(np.sin(angle_rad), resolution))
        z.append(0)
        mode.append(1)
        coord.append(0)
        # Adding data for rotation mode
        x.append(0)
        y.append(0)
        z.append(angle_fixed)
        mode.append(0)
        coord.append(0)
        # Save real data to compare with the simulation
        arctan.append(rad_to_deg(np.arctan2(np.sin(angle_rad), np.cos(angle_rad))))
        sin.append(np.sin(angle_rad))
        cos.append(np.cos(angle_rad))
        # --- Hyoperbolic coordinate system
        if (abs(angle)) < 61:
            if (abs(coding(np.sin(angle_rad), resolution) / coding(np.cos(angle_rad), resolution))) < 0.6:
                # Adding data for vectoring mode
                x.append(coding(np.cos(angle_rad), resolution))
                y.append(coding(np.sin(angle_rad), resolution))
                z.append(0)
                mode.append(1)
                coord.append(1)
                # Save real data to compare with the simulation
                arctanh.append(rad_to_deg(np.arctanh(np.sin(angle_rad) / np.cos(angle_rad))))
                axes_arctanh.append(np.sin(angle_rad) / np.cos(angle_rad))
            # Adding data for rotation mode
            x.append(0)
            y.append(0)
            z.append(angle_fixed)
            mode.append(0)
            coord.append(1)
            # Save real data to compare with the simulation
            sinh.append(np.sinh(angle_rad))
            cosh.append(np.cosh(angle_rad))
            axes_hyperbolic.append(angle_rad)
    write_file(path_inputs[0], x)
    write_file(path_inputs[1], y)
    write_file(path_inputs[2], z)
    write_file(path_inputs[3], mode)
    write_file(path_inputs[4], coord)
    write_file(path_inputs[5], enable)
    return sin, cos, arctan, sinh, cosh, arctanh, axes_circular, axes_hyperbolic, axes_arctanh


def read_files():
    path = os.path.abspath(__file__)
    path_dir, _ = os.path.split(path)
    output_dir = os.path.join(path_dir, 'output')
    files_output = get_fullpath(output_dir)
    data_output = []
    for file in files_output:
        data_output.append(read_file(file))
    return data_output


def show_results(resolution=14):
    """
    Files are read in alphabetical order
    1. Coordinate System
    2. Enable
    3. Mode
    4. X Python Values - Compute with numpy
    5. X VHDL Values
    6. Y Python Values - Compute with numpy
    7. Y VHDL Values
    8. Z Python Values - Compute with numpy
    9. Z VHDL Values 
    """
    real_values = create_files_to_simulate()
    sin_python, cos_python, arctan_python, sinh_python, cosh_python, arctanh_python, axes_circular_python, axes_hyperbolic_python, axes_arctanh_python = real_values
    data_output = read_files()
    coord, enable, mode = data_output[0], data_output[1], data_output[2]
    x, y, z = data_output[4], data_output[6], data_output[8]
    sin, cos, arctan = [], [], []
    sinh, cosh, arctanh = [], [], []
    for index in range(len(enable)):
        if enable[index] == 1: # If the module is enabled
            if coord[index] == 0: # If the module is configurate in circular coordinate system
                if mode[index] == 0: # If the module is operating in rotation mode
                    cos.append(decoding(x[index], resolution))
                    sin.append(decoding(y[index], resolution))
                else: # If the module is operating in vectoring mode
                    arctan.append(rad_to_deg(decoding(z[index], resolution)))
            else: # If the module is configure in hyperbolic coordinate system
                if mode[index] == 0: # If the module is operating in rotation mode
                    cosh.append(decoding(x[index], resolution))
                    sinh.append(decoding(y[index], resolution))
                else: # If the module is operating in vectoring mode
                    arctanh.append(rad_to_deg(decoding(z[index], resolution)))
    plot_results(cos, cos_python, axes_circular_python, 'Cos')
    plot_results(sin, sin_python, axes_circular_python, 'Sin')
    plot_results(arctan, arctan_python, axes_circular_python, 'Arctan')
    plot_results(sinh, sinh_python, axes_hyperbolic_python, 'Sinh')
    plot_results(cosh, cosh_python, axes_hyperbolic_python, 'Cosh')
    plot_results(arctanh, arctanh_python, axes_arctanh_python, 'Arctanh')


def plot_results(vhdl_values, numpy_values, axes_data, name):
    error = []
    for index in range(len(vhdl_values)):
        error.append(relative_error(numpy_values[index], vhdl_values[index]))
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(axes_data[:len(vhdl_values)], vhdl_values)
    axes[0].set_title(name)
    axes[0].set_ylabel('Amplitude')
    axes[0].set_xlabel('Angle')
    axes[0].grid()
    axes[1].plot(axes_data[:len(vhdl_values)], error, '--*')
    axes[1].set_title('Relative Error')
    axes[1].set_ylabel('Error (%)')
    axes[1].set_xlabel('Angle')
    axes[1].set_ylim(-0.8, 1.5)
    axes[1].grid()
    plt.show()
