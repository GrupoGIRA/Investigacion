"""
CORDIC Algorithm implementation
Authors:
--  Robert Limas
--  Wilson Perez
Year: 2020
"""

import numpy as np
import matplotlib.pyplot as plt
from CORDIC import coding, decoding


def write_file(file, data):
    with open(file, 'w') as f:
        for line in data:
            f.write("{}\n".format(line))


def deg2rad(value):
    return value * np.pi / 180


def rad2deg(value):
    return value * 180 / np.pi


def create_simulations_files():
    start, stop = -90, 90
    resolution = 14

    modes = {'rotation': 0, 'vectoring': 1}
    files = ["input/input_x.txt", "input/input_y.txt", "input/input_z.txt",
             "input/input_mode.txt", "input/input_enable.txt"]
    results = ["output/output_x_python.txt", "output/output_y_python.txt", "output/output_z_python.txt"]

    data, x, y, z, mode, enable = [], [], [], [], [], []
    data_cordic, x_cordic, y_cordic, z_cordic = [], [], [], []

    rank = np.linspace(start, stop, 180)

    for deg in rank:
        # Create Z data for cordic hardware implementation sin(z) and cos(z) result
        x.append(0)
        y.append(0)
        z.append(coding(deg2rad(deg), resolution))
        mode.append(modes['rotation'])
        enable.append(1)

        # Calculate sin(z) and cos(z) with numpy
        x_cordic.append(np.cos(deg2rad(deg)))
        y_cordic.append(np.sin(deg2rad(deg)))
        z_cordic.append(0)

        # Create X and Y data for cordic hardware implementation arctan2(y / x) result
        position = [np.cos(deg2rad(deg)), np.sin(deg2rad(deg))]
        x.append(coding(position[0]))
        y.append(coding(position[1]))
        z.append(0)
        mode.append(modes['vectoring'])
        enable.append(1)

        # Calculate arctan2(y / x) with numpy
        x_cordic.append(0)
        y_cordic.append(0)
        z_cordic.append(np.arctan2(position[1], position[0]))

    # Create files for hardware implementation
    data.append(x)
    data.append(y)
    data.append(z)
    data.append(mode)
    data.append(enable)
    for index, file in enumerate(files):
        write_file(file, data[index])

    # Create files for python implementation
    data_cordic.append(x_cordic)
    data_cordic.append(y_cordic)
    data_cordic.append(z_cordic)

    for index, file in enumerate(results):
        write_file(file, data_cordic[index])


def read_file(file):
    data = []
    with open(file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            data.append(line)
    return data


def absolute_error(real_value, calculate_value):
    return (np.abs(real_value - calculate_value) / real_value) * 100


def compare_results(hardware_data, software_data):
    names = {'x': 0, 'y': 1, 'z': 2, 'enable': 3, 'mode': 4}
    modes = {'rotation': 0, 'vectoring': 1}

    total_data = len(hardware_data[0])

    x_error, y_error, z_error, x, y, z = [], [], [], [], [], []

    line_software = 0
    for line in range(total_data):
        if int(hardware_data[names['enable']][line]) == 1:
            if int(hardware_data[names['mode']][line]) == modes['rotation']:
                x_error.append(
                    absolute_error(float(software_data[names['x']][line_software]),
                                   decoding(float(hardware_data[names['x']][line])))
                )
                x.append(decoding(float(hardware_data[names['x']][line])))
                y_error.append(
                    absolute_error(float(software_data[names['y']][line_software]),
                                   decoding(float(hardware_data[names['y']][line])))
                )
                y.append(decoding(float(hardware_data[names['y']][line])))
            else:
                z_error.append(
                    absolute_error(float(software_data[names['z']][line_software]),
                                   decoding(float(hardware_data[names['z']][line])))
                )
                z.append(decoding(float(hardware_data[names['z']][line])))
            line_software += 1

    return x_error, y_error, z_error, x, y, z


def draw(x, y, z, x_error, y_error, z_error):
    temp = map(lambda angle: rad2deg(angle), z)
    axes_x = np.array(list(temp))
    figure, axes = plt.subplots(3, 2)
    axes[0, 0].plot(axes_x, x[: len(z)])
    axes[0, 0].set_title("X values")
    axes[0, 0].set_xlabel("Deg")
    axes[0, 0].set_ylabel("X")
    axes[0, 0].grid()
    axes[1, 0].plot(axes_x, y[: len(z)])
    axes[1, 0].set_title("Y values")
    axes[1, 0].set_xlabel("Deg")
    axes[1, 0].set_ylabel("Y")
    axes[1, 0].grid()
    axes[2, 0].plot(axes_x, z[: len(z)])
    axes[2, 0].set_title("Z values")
    axes[2, 0].set_xlabel("Deg")
    axes[2, 0].set_ylabel("Z")
    axes[2, 0].grid()
    axes[0, 1].plot(axes_x, x_error[: len(z)])
    axes[0, 1].set_title("X Absolute Error")
    axes[0, 1].set_xlabel("Deg")
    axes[0, 1].set_ylabel("Error")
    axes[0, 1].grid()
    axes[1, 1].plot(axes_x, y_error[: len(z)])
    axes[1, 1].set_title("Y Absolute Error")
    axes[1, 1].set_xlabel("Deg")
    axes[1, 1].set_ylabel("Error")
    axes[1, 1].grid()
    axes[2, 1].plot(axes_x, z_error[: len(z)])
    axes[2, 1].set_title("Z Absolute Error")
    axes[2, 1].set_xlabel("Deg")
    axes[2, 1].set_ylabel("Error")
    axes[2, 1].grid()
    plt.show()


def implementation_error():
    hardware = ["output/output_x_vhdl.txt", "output/output_y_vhdl.txt", "output/output_z_vhdl.txt",
                "output/output_enable_vhdl.txt", "output/output_mode_vhdl.txt"]
    software = ["output/output_x_python.txt", "output/output_y_python.txt", "output/output_z_python.txt"]

    data_hardware, data_software = [], []

    # Read hardware simulation files
    for file in hardware:
        data_hardware.append(read_file(file))

    # Read software simulation files
    for file in software:
        data_software.append(read_file(file))

    x_error, y_error, z_error, x, y, z = compare_results(data_hardware, data_software)
    draw(x, y, z, x_error, y_error, z_error)


def main():
    create_simulations_files()
    implementation_error()


if __name__ == '__main__':
    main()
