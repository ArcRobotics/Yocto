import datetime
import ctypes
import os

print("""
  ____    _    _   _   ____  _   _ ____
 / ___|  / \  | \ | | | __ )| | | / ___|
| |     / _ \ |  \| | |  _ \| | | \___
| |___ / ___ \| |\  | | |_) | |_| |___) |
 \____/_/  _\_\_|_\_|_|____/_\___/|____/
/ ___|| \ | (_)  ___|  ___| ____|  _  |
\___ \|  \| | | |_  | |_  |  _| | |_) |
 ___) | |\  | |  _| |  _| | |___|  _ <
|____/|_| \_|_|_|   |_|   |_____|_| \_|
""")

# List all available log files in the current directory
log_files = [f for f in os.listdir('.') if f.endswith('.log')]

print("Available log files:")
for idx, file_name in enumerate(log_files):
    print(f"{idx + 1}. {file_name}")

# Select the log file
file_index = int(input("Select the log file number to read: ")) - 1
log_file = log_files[file_index]

# Define the output file name based on the input file name
output_file = f"{os.path.splitext(log_file)[0]}_output.cpp"

Number_of_nodes = int(input('Please enter the number of nodes:'))

# Open the output file in write mode
with open(output_file, 'w') as f_out:
    with open(log_file, 'r') as f_in:
        f_out.write("Logging CAN messages from log file\n")
        f_out.write(f"Start time: {datetime.datetime.now()}\n")
        f_out.write("-" * 50 + "\n")

        # Process each line in the log file
        for line in f_in:
            parts = line.strip().split()
            # Parse timestamp
            timestamp = float(parts[0].strip("()"))
            formatted_timestamp = datetime.datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S.%f')
            
            # Parse CAN ID and data
            id_data = parts[2].split('#')
            msg_id = int(id_data[0], 16)  # Convert ID from hex to integer
            data_hex = id_data[1]
            data = bytes.fromhex(data_hex)  # Convert hex string to bytes array
            
            # Simulate msg structure
            class SimulatedMsg:
                arbitration_id = msg_id
                dlc = len(data)
                data = data
            
            msg = SimulatedMsg()

            # Format the message for logging
            log_entry = f"{formatted_timestamp} - ID: {msg.arbitration_id:03X} DLC: {msg.dlc} Data: {' '.join(f'{byte:02X}' for byte in msg.data)}"
            message = ""
            Index = ""
            SDO_command_type = ""
            mode_of_operation = ""
            SDO = False
            nodeID = 1
            pdo_data = ""
            data_int = 0
            data2_int = 0

            for nodeID in range(1, Number_of_nodes + 1):
                if msg_id == 0x80:
                    message = "SYNC"
                elif msg_id == 0x81:
                    message = "EMCY"
                elif msg_id == (0x580 | nodeID):
                    message = "SDO Epos->Pi"
                    SDO = True
                elif msg_id == (0x600 | nodeID):
                    message = "SDO Pi->Epos"
                    SDO = True
                elif msg_id in [(0x200 | nodeID), (0x300 | nodeID), (0x400 | nodeID), (0x500 | nodeID)]:
                    message = "PDO Pi->Epos"
                    if msg_id == (0x300 | nodeID):
                        data2_int = (msg.data[7] << 24) | (msg.data[6] << 16) | (msg.data[5] << 8) | msg.data[4]
                        data_int = (msg.data[3] << 24) | (msg.data[2] << 16) | (msg.data[1] << 8) | msg.data[0]
                        data_signed = ctypes.c_int32(data_int).value
                        pdo_data = f"C={data_signed},S={data2_int}"
                    elif msg_id == (0x200 | nodeID):
                        data_int = (msg.data[1] << 8) | msg.data[0]
                        pdo_data = f"cw={data_int:b}"
                elif msg_id in [(0x180 | nodeID), (0x280 | nodeID), (0x380 | nodeID), (0x480 | nodeID)]:
                    message = "PDO Epos->Pi"
                    if msg_id == (0x180 | nodeID) and msg.data[2] == 0x01:
                        mode_of_operation = "Profile Position Mode (PPM)"
                    elif msg_id == (0x280 | nodeID):
                        data_int = (msg.data[1] << 8) | msg.data[0]
                        pdo_data = f"st={data_int:b}"
                    elif msg_id == (0x380 | nodeID):
                        data_int = (msg.data[7] << 24) | (msg.data[6] << 16) | (msg.data[5] << 8) | msg.data[4]
                        data2_int = (msg.data[3] << 24) | (msg.data[2] << 16) | (msg.data[1] << 8) | msg.data[0]
                        data_signed = ctypes.c_int32(data_int).value
                        data_signed2 = ctypes.c_int32(data2_int).value
                        pdo_data = f"C={data_signed},D={data_signed2}"

                # More message parsing if needed...

                if SDO:
                    if len(msg.data) > 2:
                        sdo_data = (msg.data[2] << 8) | msg.data[1]
                        Index = "Some Index"  # Replace with actual conditions as needed
                        SDO_command_type = "SDO Type"  # Replace with actual logic
                    
                    log_entry += f" ({message} {Index} {SDO_command_type})"
                else:
                    log_entry += f" ({message} {pdo_data}{mode_of_operation})"

            # Print to console for debugging
            print(log_entry.strip())
            
            # Write to output file
            f_out.write(log_entry + "\n")
