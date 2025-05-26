import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

# Read numeric values from a text file
def read_values_from_file(filename):
    with open(filename, 'r') as file:
        values = [float(line.strip()) for line in file if line.strip()]
    return np.array(values)

# Compute mean and standard deviation
def compute_stats(values):
    mean = np.mean(values)
    std_dev = np.std(values, ddof=1)  # Sample standard deviation
    return mean, std_dev

# Plot standard deviation (normal distribution) curve
def plot_std_curve(mean, std_dev):
    x = np.linspace(mean - 4*std_dev, mean + 4*std_dev, 1000)
    y = norm.pdf(x, mean, std_dev)

    plt.figure(figsize=(10, 6))
    plt.plot(x, y, label=f'N({mean:.3f}, {std_dev:.3f}²)', color='blue')
    plt.axvline(mean, color='red', linestyle='--', label='Mean')
    plt.fill_between(x, y, where=(x > mean - std_dev) & (x < mean + std_dev), color='blue', alpha=0.2, label='±1σ')
    plt.fill_between(x, y, where=(x > mean - 2*std_dev) & (x < mean + 2*std_dev), color='blue', alpha=0.1, label='±2σ')
    plt.title('Standard Normal Distribution Curve For SYNC timestamp')
    plt.xlabel('Time in ms')
    plt.ylabel('Probability Density')
    plt.grid(True)
    plt.legend()
    plt.show()

# Main execution
if __name__ == "__main__":
    filename = input("Enter the file name: ")
    filename = filename +".txt"  # Replace with your actual file name
    values = read_values_from_file(filename)
    mean, std_dev = compute_stats(values)
    print(f"Mean: {mean:.5f}, Std Dev: {std_dev:.5f}")
    plot_std_curve(mean, std_dev)
