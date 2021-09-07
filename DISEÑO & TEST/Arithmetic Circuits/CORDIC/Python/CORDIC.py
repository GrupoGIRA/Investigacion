"""
CORDIC algorithm implementation
Authors:
--  Robert Limas
--  Wilson Perez
Year: 2020

Inputs:
    x (required), y (required), z (required), mode (optional, default mode rotation), iterations (optional default 16)
Outputs:
    trigonometric_functions -> dictionary with trigonometric functions values and keys: sin, cos, arctan2

Description:
This algorithm works between pi/2 and -pi/2 and has two operation mode

1. Rotation
    Mode used for calculate sin and cos functions
    *** Warning: Inputs x and y should be equal to 0 and input z should be has the angle in rad ***
2. Vectoring
    Mode used for calculate arctan2(y / x) function
    *** Warning: Input z should be equal to 0 ***
"""

import numpy as np


def cordic(x, y, z, mode='rotation', u=1, iterations=16):
    const_circular, const_hyperbolic = constants_compute(iterations)
    const = 1 / const_circular if u == 1 else 1 / const_hyperbolic
    x_current = const if mode == 'rotation' and u != 0 else x
    y_current, z_current, z_next = y, z, z

    start = 1 if u == -1 else 0

    for i in range(start, iterations):
        d_current = (1 if y_current < 0 else -1) if mode == 'vectoring' else (-1 if z_next < 0 else 1)

        if u == 1:
            f = np.arctan(d_current / (np.power(2, i)))
        elif u == 0:
            f = d_current / (np.power(2, i))
        else:
            f = np.arctanh(d_current / (np.power(2, i)))

        x_next = x_current - u * (d_current * y_current) / (np.power(2, i))
        y_next = y_current + (d_current * x_current) / (np.power(2, i))
        z_next = z_current - f

        x_current, y_current, z_current = x_next, y_next, z_next

    return x_current, y_current, z_current


def cordic_fixed_point(x, y, z, mode='rotation', u=1, iterations=16, resolution=14):
    const_circular, const_hyperbolic = constants_compute(iterations)
    const = coding(1 / const_circular, resolution) if u == 1 else coding(1 / const_hyperbolic, resolution)
    x_current = const if mode == 'rotation' and u != 0 else coding(x, resolution)
    y_current, z_current, z_next = coding(y, resolution), coding(z, resolution), coding(z, resolution)

    if u == -1:
        temp = [1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13, 14, 15, 16, 17, 18, 19, 20]
    else:
        temp = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]

    for i in range(iterations):
        d_current = (1 if y_current < 0 else -1) if mode == 'vectoring' else (-1 if z_next < 0 else 1)

        if u == 1:
            f = int(np.power(2, resolution) * (np.arctan(d_current * (1 / (np.power(2, temp[i]))))))
        elif u == 0:
            f = int(np.power(2, resolution) * d_current / (np.power(2, temp[i])))
        else:
            f = int(np.power(2, resolution) * np.arctanh(d_current / (np.power(2, temp[i]))))

        x_next = int(x_current - u * (d_current * y_current) / (np.power(2, temp[i])))
        y_next = int(y_current + (d_current * x_current) / (np.power(2, temp[i])))
        z_next = int(z_current - f)

        x_current, y_current, z_current = x_next, y_next, z_next

    return decoding(x_current, resolution), decoding(y_current, resolution), decoding(z_current, resolution)


def constants_compute(iterations=14):
    circular, hyperbolic = 1.0, 1.0
    for iteration in range(iterations):
        circular = circular * np.sqrt(1 + (1 / np.power(2, 2 * iteration)))
        if iteration > 0:
            hyperbolic = hyperbolic * np.sqrt(1 - (1 / np.power(2, 2 * iteration)))
    return circular, hyperbolic


def coding(value, resolution=14):
    return int(value * np.power(2, resolution))


def decoding(value, resolution=14):
    return value / np.power(2, resolution)


def deg2rad(value):
    return value * np.pi / 180.0


def rad2deg(value):
    return value * 180.0 / np.pi
