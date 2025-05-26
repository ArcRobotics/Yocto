#!/bin/bash

show_help()
{
	echo " "
	echo " "
	echo ".----------------------------------------------------------------------.";
	echo "Please enter the name of the file next to the bash command"
	echo "Example of usage (on target ex.raspberrypi):"
	echo "This command requires rt-tests to be installed on the image"
	echo "cyclictest -p 99 -m -l 100000 -q  -h 500 > cyclictest.data"
	echo ".----------------------------------------------------------------------.";
	echo " "
	echo " "
}

show_help

# Check if an argument is provided
if [ -z "$1" ]; then
	show_help
	exit 1
fi

# Check if gnuplot is installed
if ! command -v gnuplot &> /dev/null; then
    echo "gnuplot is not installed. Installing it now..."

    # Check for package manager and install accordingly
    if [ -x "$(command -v apt)" ]; then
        sudo apt update && sudo apt install -y gnuplot
	fi
fi

# Assign the first argument to a variable
input="$1"

echo "Fetching..."
scp root@192.168.1.100:/home/root/${input}.data .

echo "Plotting data and exporting it as ${input}_histogram.png image"
# Start gnuplot and feed it commands
gnuplot <<EOF
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xlabel "microseconds"
set ylabel "samples"
set title "Histogram of Cyclic test RT-PATCH"
set xrange [0:50]  # Limit the x-axis range from 0 to 500
set xtics rotate by -45
set terminal png
set terminal png size 2560,1440  # Set image size to 2560,1440 pixels
set output "${input}_histogram.png"
plot "${input}.data" using 2:xtic(1) title "Cyclic Test Counts"
set output
EOF