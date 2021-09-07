"""
CORDIC Algorithm implementation
Authors:
--  Robert Alexander Limas S
--  Wilson Javier Perez H
Year: 2020
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from CORDIC import *

matplotlib.rcParams.update({'font.size': 22})


def write_file(file, data):
    with open(file, 'w') as f:
        for line in data:
            f.write("{}\n".format(line))


def read_file(file):
    data = []
    with open(file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            data.append(int(line))
    return data


def relative_error(real_value, calculate_value):
    return (real_value - calculate_value) / real_value * 100


def mean(array):
    total = 0
    for item in array:
        if item == float("+inf") or item == float("-inf"):
            print("Inf")
        else:
            print("No inf")
            total += item
    return total / len(array)


def variance(mean, array):
    total = 0
    for item in array:
        if item == float("+inf") or item == float("-inf"):
            print("Inf")
        else:
            print("No inf")
            total += np.power((item - mean), 2)
    return total / len(array)


def results(python, vhdl):
    labels = ["Sin", "Cos", "ArcTan", "Sin Hyperbolic", "Cos Hyperbolic", "ArcTanH"]
    # for graphs in range(len(vhdl)):

    error = []
    graphs = 1
    axes_ = 0
    for item in range(len(python[graphs])):
        try:
            error.append(relative_error(python[graphs][item], vhdl[graphs][item]))
        except Exception as ex:
            print(ex)
    average = mean(error)
    variance_ = variance(average, error)
    standard_deviation = np.sqrt(variance_)
    print(f"Error {labels[graphs]} mean: {round(average, 5)}, variance: {round(variance_, 5)}, standard_deviation: {round(standard_deviation, 5)}")
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(python[axes_][:len(vhdl[graphs])], vhdl[graphs])
    axes[0].set_title(f"{labels[graphs]}")
    # axes[0].set_ylim(-1.1, 1.1)
    axes[0].set_ylabel("Amplitude")
    axes[0].set_xlabel("Deg")
    axes[0].grid()
    axes[1].plot(python[axes_][:len(vhdl[graphs])], error, '--*')
    axes[1].set_title("Relative Error")
    axes[1].set_ylim(-0.8, 1.5)
    axes[1].set_ylabel("Error (%)")
    axes[1].set_xlabel("")
    axes[1].grid()
    plt.show()


def create_files():
    start, end = -89, 89
    resolution = 14
    inputs_files = ['./input/input_x.txt', './input/input_y.txt', './input/input_z.txt', './input/input_mode.txt',
                    './input/input_coor.txt', './input/input_enable.txt']
    x, y, z = [], [], []
    enable, mode, coor = [], [], []
    sin, cos, arctan = [], [], []
    sinh, cosh, arctanh = [], [], []
    axes_sin_cos, axes_sinh_cosh, axes_tanh = [], [], []
    for angle in range(start, end):
        angle_rad = deg2rad(angle)
        angle_fixed = coding(angle_rad, resolution)
        axes_sin_cos.append(angle)
        
        # Adding data for vectoring mode in circular coordinate
        x.append(coding(np.cos(angle_rad), resolution))
        y.append(coding(np.sin(angle_rad), resolution))
        z.append(0)
        enable.append(1)
        mode.append(1)
        coor.append(0)
        arctan.append(np.arctan2(np.sin(angle_rad), np.cos(angle_rad)))

        # Adding data for rotation mode in circular coordinate
        x.append(0)
        y.append(0)
        z.append(angle_fixed)
        enable.append(1)
        mode.append(0)
        coor.append(0)
        sin.append(np.sin(angle_rad))
        cos.append(np.cos(angle_rad))

        if np.abs(angle) < 61:
            # Adding data for vectoring mode in hyperbolic coordinate
            if np.abs(coding(np.sin(angle_rad)) / coding(np.cos(angle_rad))) < 0.6:
                x.append(coding(np.cos(angle_rad), resolution))
                y.append(coding(np.sin(angle_rad), resolution))
                z.append(0)
                enable.append(1)
                mode.append(1)
                coor.append(1)
                arctanh.append(np.arctanh(np.sin(angle_rad) / np.cos(angle_rad)))
                axes_tanh.append(np.sin(angle_rad) / np.cos(angle_rad))

            # Adding data for rotation mode in hyperbolic coordinate
            x.append(0)
            y.append(0)
            z.append(angle_fixed)
            enable.append(1)
            mode.append(0)
            coor.append(1)
            sinh.append(np.sinh(angle_rad))
            cosh.append(np.cosh(angle_rad))
            axes_sinh_cosh.append(angle)

    write_file(inputs_files[0], x)
    write_file(inputs_files[1], y)
    write_file(inputs_files[2], z)
    write_file(inputs_files[3], mode)
    write_file(inputs_files[4], coor)
    write_file(inputs_files[5], enable)
    return [sin, cos, arctan, sinh, cosh, arctanh, axes_sin_cos, axes_sinh_cosh, axes_tanh]


def read_files():
    outputs_files = ['./output/output_x_vhdl.txt', './output/output_y_vhdl.txt', './output/output_z_vhdl.txt',
                     './output/output_mode_vhdl.txt', './output/output_coor_vhdl.txt',
                     './output/output_enable_vhdl.txt']
    x = read_file(outputs_files[0])
    y = read_file(outputs_files[1])
    z = read_file(outputs_files[2])
    mode = read_file(outputs_files[3])
    coor = read_file(outputs_files[4])
    enable = read_file(outputs_files[5])
    sin, cos, arctan = [], [], []
    sinh, cosh, arctanh = [], [], []
    resolution = 14
    for index in range(len(mode)):
        if enable[index] == 1:  # Data process
            if coor[index] == 0:  # Circular coordinate system
                if mode[index] == 0:  # Rotation mode
                    cos.append(decoding(x[index], resolution))
                    sin.append(decoding(y[index], resolution))
                else:  # Vectoring mode
                    arctan.append(decoding(z[index], resolution))
            else:  # Hyperbolic coordinate system
                if mode[index] == 0:  # Rotation mode
                    cosh.append(decoding(x[index], resolution))
                    sinh.append(decoding(y[index], resolution))
                else:  # Vectoring mode
                    arctanh.append(decoding(z[index], resolution))

    return [sin, cos, arctan, sinh, cosh, arctanh]


def calculate_iterations(resolution=14):
    steps = range(1, 17)
    angle = 45
    x, y = 1.0, 1.0
    angle_rad = deg2rad(angle)
    artan, artan_numpy = [], []
    sin, sin_numpy = [], []
    for step in steps:
        artan_numpy.append(np.arctan2(y, x))
        artan.append(cordic_fixed_point(x, y, 0.0, mode='vectoring', resolution=resolution, iterations=step)[2])
        sin_numpy.append(np.sin(angle_rad))
        sin.append(cordic_fixed_point(0.0, 0.0, angle_rad, resolution=resolution, iterations=step)[1])
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(steps, artan, 'k*-')
    axes[0].plot(steps, artan_numpy, 'b--')
    axes[0].set_title(f"Atan2 value {x} X and {y} Y")
    axes[0].set_ylabel("Value")
    axes[0].set_xlabel("Iterations")
    axes[0].legend(['CORDIC compute', 'Numpy compute'])
    axes[0].grid(color='grey', linestyle='dotted', linewidth=1)
    axes[1].plot(steps, sin, 'k*-')
    axes[1].plot(steps, sin_numpy, 'b--')
    axes[1].set_title(f"Sin value {angle}°")
    axes[1].set_ylabel("Value")
    axes[1].set_xlabel("Iterations")
    axes[1].legend(['CORDIC compute', 'Numpy compute'])
    axes[1].grid(color='grey', linestyle='dotted', linewidth=1)
    plt.show()


def calculate_resolutions(iterations=16):
    steps = range(1, 20)
    angle = 45
    x, y = 1.0, 1.0
    angle_rad = deg2rad(angle)
    artan, artan_numpy = [], []
    sin, sin_numpy = [], []
    for step in steps:
        artan_numpy.append(np.arctan2(y, x))
        artan.append(cordic_fixed_point(x, y, 0.0, mode='vectoring', resolution=step, iterations=iterations)[2])
        sin_numpy.append(np.sin(angle_rad))
        sin.append(cordic_fixed_point(0.0, 0.0, angle_rad, resolution=step, iterations=iterations)[1])
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(steps, artan, 'k*-')
    axes[0].plot(steps, artan_numpy, 'b--')
    axes[0].set_title(f"Atan2 value {x} X and {y} Y")
    axes[0].set_ylabel("Value")
    axes[0].set_xlabel("Resolution in Bits")
    axes[0].legend(['CORDIC compute', 'Numpy compute'])
    axes[0].grid(color='grey', linestyle='dotted', linewidth=1)
    axes[1].plot(steps, sin, 'k*-')
    axes[1].plot(steps, sin_numpy, 'b--')
    axes[1].set_title(f"Sin value {angle}°")
    axes[1].set_ylabel("Value")
    axes[1].set_xlabel("Resolution in Bits")
    axes[1].legend(['CORDIC compute', 'Numpy compute'])
    axes[1].grid(color='grey', linestyle='dotted', linewidth=1)
    plt.show()


def main():
    python = create_files()
    vhdl = read_files()
    results(python, vhdl)
    # calculate_resolutions()


if __name__ == '__main__':
    main()
