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


def cordic(x, y, z, mode='rotation', iterations=16):
    trigonometric_functions = dict()
    x_current = 1 / 1.6468 if mode == 'rotation' else x
    y_current, z_current, z_next = y, z, z

    for i in range(iterations):

        d_current = (1 if y_current < 0 else -1) if mode == 'vectoring' else (-1 if z_next < 0 else 1)

        x_next = x_current - (d_current * y_current) / (np.power(2, i))
        y_next = y_current + (d_current * x_current) / (np.power(2, i))
        z_next = z_current - (np.arctan(d_current * (1 / (np.power(2, i)))))

        x_current, y_current, z_current = x_next, y_next, z_next

    trigonometric_functions['cos'] = x_current
    trigonometric_functions['sin'] = y_current
    trigonometric_functions['arctan2'] = z_current

    return trigonometric_functions


def cordic_fixed_point(x, y, z, mode='rotation', iterations=16, resolution=14):
    trigonometric_functions = dict()
    x_current = int(np.power(2, resolution) / 1.6468) if mode == 'rotation' else x
    y_current, z_current, z_next = y, z, z

    for i in range(iterations):

        d_current = (1 if y_current < 0 else -1) if mode == 'vectoring' else (-1 if z_next < 0 else 1)

        x_next = int(x_current - (d_current * y_current) / (np.power(2, i)))
        y_next = int(y_current + (d_current * x_current) / (np.power(2, i)))
        z_next = int(z_current - int(np.power(2, resolution) * (np.arctan(d_current * (1 / (np.power(2, i)))))))

        x_current, y_current, z_current = x_next, y_next, z_next

    trigonometric_functions['cos'] = x_current
    trigonometric_functions['sin'] = y_current
    trigonometric_functions['arctan2'] = z_current

    return trigonometric_functions


def coding(value, resolution=14):
    return int(value * np.power(2, resolution))


def decoding(value, resolution=14):
    return value / np.power(2, resolution)