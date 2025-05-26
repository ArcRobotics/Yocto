import can
import datetime
import ctypes

# Define the log file name
log_file = "can0_log.cpp"

# Create a Bus instance to listen on the 'can0' interface
bus = can.interface.Bus(channel='can0', bustype='socketcan')

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

Number_of_nodes = int(input('Please enter the number of nodes:'))

previous_sync_time = datetime.datetime.now()
current_time = None
sync_time_only_log_flag = input('Log Sync time only? (y/n): ')
sync_time_only_log = False

print_to_console_flag = input('Print to console? (y/n): ')

if(sync_time_only_log_flag == None or sync_time_only_log_flag == 'n'):
	sync_time_only_log = False
else :
	print("Sync time only log enabled")
	sync_time_only_log = True


def calculate_time_diff(file,current_time,previous_sync_time):
	time_diff = (current_time - previous_sync_time).total_seconds() * 1000.0
	previous_sync_time = current_time
	if(time_diff > 1):
		# print(f"Delta_Time: {time_diff:.2f} ms")
		file.write(f"SyncTime = {time_diff}\n")

# Open the log file in append mode
with open(log_file, 'a') as f:
	f.write("Logging CAN messages from can0 interface\n")
	f.write(f"Start time: {datetime.datetime.now()}\n")
	f.write("-" * 50 + "\n")

	# Listen to the CAN bus
	while True:
		# Wait for a message
		msg = bus.recv()

		# Get the current timestamp
		timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')

		# Format the message
		log_entry = f"{timestamp} - ID: {msg.arbitration_id:03X} DLC: {msg.dlc} Data: {' '.join(f'{byte:02X}' for byte in msg.data)}"
		id = msg.arbitration_id
		message = ""
		Index = ""
		SDO_command_type = ""
		mode_of_operation = ""
		SDO = False
		nodeID = 1
		pdo_data = ""
		data = 0
		data2 = 0

		for nodeID in range(1, Number_of_nodes + 1):
			if sync_time_only_log == True:
				if(id == 0x80):
					message = "SYNC"
					current_time = datetime.datetime.now()
					time_diff = (current_time - previous_sync_time).total_seconds() * 1000.0
					previous_sync_time = current_time
					if(time_diff > 1):
						# print(f"Delta_Time: {time_diff:.2f} ms")
						f.write(f"SyncTime = {time_diff}\n")
			else:
				if(id == 0x80):
					message = "SYNC"
					current_time = datetime.datetime.now()
					calculate_time_diff(f,current_time,previous_sync_time)
				elif (id == 0x80|nodeID):
					message = f"EMCY at node{nodeID}"
				elif (id == (0x580|nodeID)):
					message = "SDO Epos->Pi"
					SDO = True
				elif (id == (0x600|nodeID)):
					message = "SDO Pi->Epos"
					SDO = True
				elif (id == (0x200|nodeID) or id ==  (0x300|nodeID) or id ==  (0x400|nodeID) or id ==  (0x500|nodeID)):
					message = "PDO Pi->Epos"

					if(id == (0x300|nodeID)):
						data2 = (msg.data[7] << 24) | (msg.data[6] << 16) | (msg.data[5] << 8) | msg.data[4]
						data = (msg.data[3] << 24) | (msg.data[2] << 16) | (msg.data[1] << 8) | msg.data[0]

						# Convert it to a signed 32-bit integer
						data_signed = ctypes.c_int32(data).value

						pdo_data = f"CMD={data_signed},Speed={data2}"
					elif(id == (0x200|nodeID)):
						data = (msg.data[1] << 8) | msg.data[0]
						pdo_data = f"cw={data:b}"
				elif (id ==  (0x180|nodeID) or id ==  (0x280|nodeID) or id ==  (0x380|nodeID) or id ==  (0x480|nodeID)):
					message = "PDO Epos->Pi"

					#Read the 3rd byte and print the mode
					if(id == (0x180|nodeID)):
						if(msg.data[2] == 0x01):
							mode_of_operation = "Profile Position Mode (PPM)"
						elif(msg.data[2] == 0x06):
							mode_of_operation = "Homing Mode (HMM)"
						elif(msg.data[2] == 0x08):
							mode_of_operation = "Cyclic Synchronous Position Mode (CSP)"
					elif(id == (0x280|nodeID)):
						data = (msg.data[1] << 8) | msg.data[0]
						pdo_data = f"st={data:b}"
					elif(id == (0x380|nodeID)):
						data = (msg.data[7] << 24) | (msg.data[6] << 16) | (msg.data[5] << 8) | msg.data[4]
						data2 = (msg.data[3] << 24) | (msg.data[2] << 16) | (msg.data[1] << 8) | msg.data[0]

						# Convert data to a signed 32-bit integer
						data_signed = ctypes.c_int32(data).value
						data_signed2 = ctypes.c_int32(data2).value

						pdo_data = f"CMD={data_signed},DMND={data_signed2}"


				elif (id == 0x77F):
					message = "Heart beat"
				elif (id == (0x700|nodeID)):
					first_byte = msg.data[0]
					if(first_byte == 0x00):
						message = "HB EPOS->Boot-Up"
					elif(first_byte == 0x04):
						message = "HB EPOS->Stopped"
					elif(first_byte == 0x05):
						message = "HB EPOS->Operational"
					elif(first_byte == 0x7f):
						message = "HB EPOS->Pre-Operational"

				elif (id == 0x00):
					if len(msg.data) > 1:
						first_byte = msg.data[0]
					if(first_byte == 0x82):
						message = f"NMT->RstComm"
					elif(first_byte == 0x02):
						message = f"NMT->Stop"
					elif(first_byte == 0x01):
						message = f"NMT->Start"
				if (SDO == True):
					if msg.dlc > 7:
						#since the LSB is sent first we take the MSB shift it left by a byte then add the LSB
						data = (msg.data[2] << 8) | msg.data[1]
						#print(f"Combined value: {data:04X}") #for debugging uncomment this line

						if(data == 0x1A00):
							Index = "TxPDO1 map"
						elif(data == 0x1A01):
							Index = "TxPDO2 map"
						elif(data == 0x1A02):
							Index = "TxPDO3 map"
						elif(data == 0x1A03):
							Index = "TxPDO4 map"
						elif(data == 0x1800):
							Index = "TxPDO1 para"
						elif(data == 0x1801):
							Index = "TxPDO2 para"
						elif(data == 0x1802):
							Index = "TxPDO3 para"
						elif(data == 0x1803):
							Index = "TxPDO4 para"
						elif(data == 0x1600):
							Index = "RxPDO1 map"
						elif(data == 0x1601):
							Index = "RxPDO2 map"
						elif(data == 0x1602):
							Index = "RxPDO3 map"
						elif(data == 0x1603):
							Index = "RxPDO4 map"
						elif(data == 0x1400):
							Index = "RxPDO1 para"
						elif(data == 0x1401):
							Index = "RxPDO2 para"
						elif(data == 0x1402):
							Index = "RxPDO3 para"
						elif(data == 0x1403):
							Index = "RxPDO4 para"

						#define each command in the 1st SDO byte
						if(msg.data[0] == 0x40):
							SDO_command_type = "Upload Request (Any data size)"
						elif(msg.data[0] == 0x4F):
							SDO_command_type = "Upload Response (Data size 1byte)"
						elif(msg.data[0] == 0x4B):
							SDO_command_type = "Upload Response (Data size 2byte)"
						elif(msg.data[0] == 0x43):
							SDO_command_type = "Upload Response (Data size 4byte)"
						elif(msg.data[0] == 0x2F):
							SDO_command_type = "Download Request (Data size 1byte)"
						elif(msg.data[0] == 0x2B):
							SDO_command_type = "Download Request (Data size 2byte)"
						elif(msg.data[0] == 0x23):
							SDO_command_type = "Download Request (Data size 4byte)"
						elif(msg.data[0] == 0x60):
							SDO_command_type = "Download Response (Successful)"
						elif(msg.data[0] == 0x80):
							SDO_command_type = "Abort Domain Transfer (Write Unsuccessful)"


			if (SDO == True):
				log_entry = log_entry+" ("+message+" "+Index+" "+SDO_command_type+")"+"\n"
			else:
				log_entry = log_entry+" ("+message+" "+pdo_data+mode_of_operation+")"+"\n"

		if print_to_console_flag == 'y':
			# Print the message to the console (optional) for debugging disable it for faster read/write cycle
			print(log_entry.strip())

		if not sync_time_only_log:
			# Write the message to the log file
			f.write(log_entry)
