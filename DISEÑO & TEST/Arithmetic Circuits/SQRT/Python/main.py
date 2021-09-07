"""
SQRT int algorithm implementation
Authors:
--  Robert Alexander Limas S
--  Wilson Javier Perez H
Year: 2021

Inputs:
    txt file with the hardware implementation values
"""
import os
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

matplotlib.rcParams.update({'font.size': 22})


def complete_with_zeros(data, size=16):
    size_data = len(data)
    miss = size - size_data
    for i in range(miss):
        data = '0' + data
    return data


def complete_decimal(data_root, data_decimal):
    data = data_root[-8:]
    decimal = data + data_decimal
    root_int = data_root[:8]
    return root_int, decimal


def bin_to_decimal(binary, n):
    decimal = 0
    for digit in binary:
        decimal = decimal + int(digit) * (2 ** n)
        n = n - 1
    return decimal


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


def read_files():
    base_path = os.getcwd()
    root_path = os.path.join(base_path, 'root_int.txt')
    remainder_path = os.path.join(base_path, 'root_decimal.txt')
    root, remainder = [], []
    with open(root_path, 'r') as file:
        for line in file.readlines():
            root.append(int(line))
    with open(remainder_path, 'r') as file:
        for line in file.readlines():
            remainder.append(int(line))
    return root, remainder


def main():
    root, remainder = read_files()
    root_binary, remainder_binary = [], []
    for value in root:
        temp = '{0:b}'.format(value)
        root_binary.append(complete_with_zeros(temp))
    for value in remainder:
        temp = '{0:b}'.format(value)
        remainder_binary.append(complete_with_zeros(temp))
    root_int, remainder = [], []
    for index in range(len(root_binary)):
        int_aux, remainder_aux = complete_decimal(root_binary[index], remainder_binary[index])
        root_int.append(int_aux)
        remainder.append(remainder_aux)
    roots, x = [], []
    error = []
    for index in range(len(remainder)):
        x.append(index + 1)
        int_temp = bin_to_decimal(root_int[index], n=len(root_int[index])-1)
        decimal_temp = bin_to_decimal(remainder[index], n=-1)
        roots.append(int_temp + decimal_temp)
        error.append(relative_error(np.sqrt(index+1), int_temp + decimal_temp))
    average = mean(error)
    variance_ = variance(average, error)
    standard_deviation = np.sqrt(variance_)
    print(f"Error mean: {round(average, 5)}, variance: {round(variance_, 5)}, standard_deviation: {round(standard_deviation, 5)}")
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(x, roots)
    axes[0].set_title("SQRT Values")
    axes[0].set_ylabel("Root")
    axes[0].set_xlabel("Radicand")
    axes[0].grid()
    axes[1].plot(x, error, '--*')
    axes[1].set_title("Relative Error")
    axes[1].set_ylim(-0.8, 1.5)
    axes[1].set_ylabel("Error (%)")
    axes[1].set_xlabel("Radicand")
    axes[1].grid()
    plt.show()


if __name__ == '__main__':
    main()
