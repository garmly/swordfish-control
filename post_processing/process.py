import numpy as np
import numpy as np
import numpy as np
import tkinter as tk
from tkinter import filedialog

import matplotlib.pyplot as plt

root = tk.Tk()
root.withdraw()

# Open file dialog to select a file
filename = filedialog.askopenfilename()
data = np.zeros(())

# Read the binary file
with open(filename, "rb") as file:
    file_length = len(file.read())
    file.seek(0)  # Reset file pointer to the beginning

    data = np.zeros((file_length // 24, 5))

    # Go through each reading
    for i in range(file_length // 24):
        # Read the timestamp
        timestamp_bytes = file.read(8)
        data[i,0] = int.from_bytes(timestamp_bytes, byteorder="big")
        for j in range(1, 5):
            # Read the data
            data[i,j] = int.from_bytes(file.read(4), byteorder="big")

    # Close the file
    file.close()

# Plot the data in four subplots
fig, axs = plt.subplots(4, 1, figsize=(8, 10))

# Plot the data in four subplots
for i in range(4):
    axs[i].plot(data[:, 0] - data[0,0], data[:, i+1])
    axs[i].set_ylabel(f'Value {i+1}')
    axs[i].grid()


axs[3].set_xlabel('Timestamp')

plt.suptitle('Data Plot')
plt.tight_layout()
plt.show()