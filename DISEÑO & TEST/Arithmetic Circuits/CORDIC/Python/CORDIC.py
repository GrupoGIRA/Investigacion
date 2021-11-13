"""
CORDIC algorithm implementation
Authors:
--  Robert Alexander Limas Sierra
--  Wilson Javier Perez Holguin
Year: 2020
"""
import numpy as np
from utils import deg_to_rad, load_settings, rad_to_deg


class Cordic:
    def __init__(self):
        linear_data, cuircular_data, hyperbolic_data, _ = load_settings()
        self.__linear_data = linear_data
        self.__circular_data = cuircular_data
        self.__hyperbolic_data = hyperbolic_data
        self.__constants_compute()

    def cos_sin(self, angle_deg):
        angle_rad = deg_to_rad(angle_deg)
        x_current = self.__const_circular
        y_current, z_current = 0.0, angle_rad
        x, y, _ = self.__iterations_compute(x_current, y_current, z_current, mode='rotation', coord='circular')
        return x, y

    def arctan(self, x, y):
        x_current = x
        y_current, z_current = y, 0.0
        _, _, z = self.__iterations_compute(x_current, y_current, z_current, mode='vectoring', coord='circular')
        return rad_to_deg(z)

    def cosh_sinh(self, angle_deg):
        angle_rad = deg_to_rad(angle_deg)
        x_current = self.__const_hyperbolic
        y_current, z_current = 0.0, angle_rad
        x, y, _ = self.__iterations_compute(x_current, y_current, z_current, mode='rotation', coord='hyperbolic')
        return x, y

    def arctanh(self, x, y):
        x_current = x
        y_current, z_current = y, 0.0
        _, _, z = self.__iterations_compute(x_current, y_current, z_current, mode='vectoring', coord='hyperbolic')
        return rad_to_deg(z)

    def product(self, x, z):
        x_current = x
        y_current, z_current = 0.0, z
        _, y, _ = self.__iterations_compute(x_current, y_current, z_current, mode='rotation', coord='linear')
        return y

    def division(self, x, y):
        x_current = x
        y_current, z_current = y, 0.0
        _, _, z = self.__iterations_compute(x_current, y_current, z_current, mode='vectoring', coord='linear')
        return z

    def __iterations_compute(self, x_current, y_current, z_current, mode, coord):
        data_iterations = self.__select_items(coord)
        u = self.__select_u(coord)
        for i in data_iterations:
            d = self.__select_d(mode, y_current, z_current)
            f = self.__select_f(coord, d, i)
            x_next = x_current - u * ((d * y_current) / (2 ** i))
            y_next = y_current + ((d * x_current) / (2 ** i))
            z_next = z_current - f
            x_current, y_current, z_current = x_next, y_next, z_next
        return x_current, y_current, z_current
    
    def __select_u(self, coord):
        if coord == 'circular':
            return 1
        elif coord == 'hyperbolic':
            return -1
        else:
            return 0

    def __select_f(self, coord, d, i):
        if coord == 'circular':
            return np.arctan(d / (2 ** i))
        elif coord == 'hyperbolic':
            return np.arctanh(d / (2 ** i))
        else:
            return d / (2 ** i)

    def __select_d(self, mode, y_current, z_current):
        if mode == 'vectoring':
            return 1 if y_current < 0 else -1
        else:
            return -1 if z_current < 0 else 1

    def __select_items(self, coord):
        if coord == 'circular':
            return self.__circular_data
        elif coord == 'hyperbolic':
            return self.__hyperbolic_data
        else:
            return self.__linear_data

    def __constants_compute(self):
        const_circular, const_hyperbolic = 1.0, 1.0
        for i in range(len(self.__circular_data)):
            const_circular = const_circular * np.sqrt(1 + (1 / (2 ** (2 * i))))
        for i in range(len(self.__hyperbolic_data)):
            const_hyperbolic = const_hyperbolic * np.sqrt(1 - (1 / (2 ** (2 * (i + 1)))))
        self.__const_circular, self.__const_hyperbolic = 1 / const_circular, 1 / const_hyperbolic
