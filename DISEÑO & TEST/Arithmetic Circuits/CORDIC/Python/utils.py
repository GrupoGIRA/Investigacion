"""
CORDIC Algorithm implementation
Authors:
--  Robert Alexander Limas Sierra
--  Wilson Javier Perez Holguin
Year: 2020
"""
import json, os
import numpy as np


def load_settings():
    abs_file_path = os.path.abspath(__file__)
    path, _ = os.path.split(abs_file_path)
    settings_path = os.path.join(path, 'settings.json')
    with open(settings_path, 'r') as f:
        data = json.load(f)
    return data['linear'], data['cuircular'], data['hyperbolic'], data['resolution']


def coding(value, resolution=14):
    return int(value * (2 ** resolution))


def decoding(value, resolution=14):
    return value / (2 ** resolution)


def deg_to_rad(value):
    return value * np.pi / 180


def rad_to_deg(value):
    return value * 180 / np.pi


def relative_error(real_value, calculate_value):
    return ((real_value - calculate_value) / real_value) * 100


def mean(values):
    total = 0
    for value in values:
        total += value
    return total / len(values)


def variance(values, mean):
    total = 0
    for value in values:
        total += ((value - mean) ** 2)
    return total / len(values)


def write_file(filename, data):
    with open(filename, 'w') as f:
        for line in data:
            f.write('{}\n'.format(line))


def read_file(file):
    data = []
    with open(file, 'r') as f:
        for line in f.readlines():
            data.append(float(line))
    return data


def get_filenames(path_dir):
    return os.listdir(path_dir)


def get_fullpath(path):
    filenames = get_filenames(path)
    fullpath = []
    for filename in filenames:
        fullpath.append(os.path.join(path, filename))
    return fullpath
