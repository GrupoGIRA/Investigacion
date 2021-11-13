"""
CORDIC algorithm implementation
Authors:
--  Robert Alexander Limas Sierra
--  Wilson Javier Perez Holguin
Year: 2020
"""
import numpy as np
from utils import coding, decoding, deg_to_rad, load_settings, rad_to_deg


class Cordic:
    def __init__(self, resolution_param='', iterations_param=''):
        linear_data, cuircular_data, hyperbolic_data, resolution = load_settings()
        self.__linear_data = linear_data
        self.__circular_data = cuircular_data
        self.__hyperbolic_data = hyperbolic_data
        if (resolution_param != ''):
            self.__resolution = resolution_param
        else:
            self.__resolution = resolution
        self.__iterations = iterations_param
        self.__constants_compute()

    def cos_sin(self, angle_deg):
        angle_rad = coding(deg_to_rad(angle_deg), self.__resolution)
        x_current = self.__const_circular
        y_current, z_current = 0.0, angle_rad
        x, y, _ = self.__iterations_compute(x_current, y_current, z_current, mode='rotation', coord='circular')
        return x, y

    def arctan(self, x, y):
        x_current = coding(x, self.__resolution)
        y_current, z_current = coding(y, self.__resolution), 0.0
        _, _, z = self.__iterations_compute(x_current, y_current, z_current, mode='vectoring', coord='circular')
        return rad_to_deg(z)

    def cosh_sinh(self, angle_deg):
        angle_rad = coding(deg_to_rad(angle_deg), self.__resolution)
        x_current = self.__const_hyperbolic
        y_current, z_current = 0.0, angle_rad
        x, y, _ = self.__iterations_compute(x_current, y_current, z_current, mode='rotation', coord='hyperbolic')
        return x, y

    def arctanh(self, x, y):
        x_current = coding(x, self.__resolution)
        y_current, z_current = coding(y, self.__resolution), 0.0
        _, _, z = self.__iterations_compute(x_current, y_current, z_current, mode='vectoring', coord='hyperbolic')
        return rad_to_deg(z)

    def product(self, x, z):
        x_current = coding(x, self.__resolution)
        y_current, z_current = 0.0, coding(z, self.__resolution)
        _, y, _ = self.__iterations_compute(x_current, y_current, z_current, mode='rotation', coord='linear')
        return y

    def division(self, x, y):
        x_current = coding(x, self.__resolution)
        y_current, z_current = coding(y, self.__resolution), 0.0
        _, _, z = self.__iterations_compute(x_current, y_current, z_current, mode='vectoring', coord='linear')
        return z

    def __iterations_compute(self, x_current, y_current, z_current, mode, coord):
        data_iterations = self.__select_items(coord)
        u = self.__select_u(coord)
        for i in data_iterations:
            d = self.__select_d(mode, y_current, z_current)
            f = self.__select_f(coord, d, i)
            x_next = int(x_current - u * ((d * y_current) / (2 ** i)))
            y_next = int(y_current + ((d * x_current) / (2 ** i)))
            z_next = int(z_current - f)
            x_current, y_current, z_current = x_next, y_next, z_next
        x = decoding(x_current, self.__resolution)
        y = decoding(y_current, self.__resolution)
        z = decoding(z_current, self.__resolution)
        return x, y, z
    
    def __select_u(self, coord):
        if coord == 'circular':
            return 1
        elif coord == 'hyperbolic':
            return -1
        else:
            return 0

    def __select_f(self, coord, d, i):
        if coord == 'circular':
            f = np.arctan(d / (2 ** i))
        elif coord == 'hyperbolic':
            f = np.arctanh(d / (2 ** i))
        else:
            f = d / (2 ** i)
        return coding(f, self.__resolution)

    def __select_d(self, mode, y_current, z_current):
        if mode == 'vectoring':
            return 1 if y_current < 0 else -1
        else:
            return -1 if z_current < 0 else 1

    def __select_items(self, coord):
        if coord == 'circular':
            data = self.__circular_data
        elif coord == 'hyperbolic':
            data = self.__hyperbolic_data
        else:
            data = self.__linear_data
        if (self.__iterations != ''):
            data = data[:self.__iterations]
        return data

    def __constants_compute(self):
        const_circular, const_hyperbolic = 1.0, 1.0
        for i in range(len(self.__circular_data)):
            const_circular = const_circular * np.sqrt(1 + (1 / (2 ** (2 * i))))
        for i in range(len(self.__hyperbolic_data)):
            const_hyperbolic = const_hyperbolic * np.sqrt(1 - (1 / (2 ** (2 * (i + 1)))))
        self.__const_circular =  coding(1 / const_circular, self.__resolution)
        self.__const_hyperbolic = coding(1 / const_hyperbolic, self.__resolution)
