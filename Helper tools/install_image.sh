#!/bin/bash
echo " "
echo " "
echo ".----------------------------------------------------------------------.";
echo "| █████╗ ██████╗  ██████╗                                              |";
echo "|██╔══██╗██╔══██╗██╔════╝                                              |";
echo "|███████║██████╔╝██║                                                   |";
echo "|██╔══██║██╔══██╗██║                                                   |";
echo "|██║  ██║██║  ██║╚██████╗                                              |";
echo "|╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝                                              |";
echo "|                                                                      |";
echo "|██╗   ██╗ ██████╗  ██████╗████████╗ ██████╗                           |";
echo "|╚██╗ ██╔╝██╔═══██╗██╔════╝╚══██╔══╝██╔═══██╗                          |";
echo "| ╚████╔╝ ██║   ██║██║        ██║   ██║   ██║                          |";
echo "|  ╚██╔╝  ██║   ██║██║        ██║   ██║   ██║                          |";
echo "|   ██║   ╚██████╔╝╚██████╗   ██║   ╚██████╔╝                          |";
echo "|   ╚═╝    ╚═════╝  ╚═════╝   ╚═╝    ╚═════╝                           |";
echo "|                                                                      |";
echo "|██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ |";
echo "|██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗|";
echo "|██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝|";
echo "|██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗|";
echo "|██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║|";
echo "|╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝|";
echo "'----------------------------------------------------------------------'";


show_warnings() {
    echo "Please make sure that:"
    echo "1-You have connected the sd card"
    echo "2-You are using in the directory where the .bz2 and .map file exist"
	echo "3-Use lsblk to find the mount of the sd card"
    echo " "
}

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-image>.wic.bz2"
    show_warnings
    exit 1
fi

#check that the SD card is connected
if [ ! -e /dev/sdb ]; then
    echo "/dev/sdb not found. Exiting."
    show_warnings
    exit 1
fi

# Assign the first argument to a variable
input="$1"

echo "changing read/write permissions"
echo " "
sudo chmod 666 /dev/sdb

echo "unmounting the disk"
echo " "
sudo umount /dev/sdb1

echo "installing the image"
echo " "
# Use bmaptool with the provided input file
sudo bmaptool copy "${input}" /dev/sdb
