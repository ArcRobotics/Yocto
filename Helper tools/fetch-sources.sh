#!/bin/bash

#This code fetches sources using Github ssh protocol
#The code also automatically switch to scarthgap branch and create a file called sources

# Define repositories (using SSH)
POKY_REPO="git@github.com:yoctoproject/poky.git"
META_OPENEMBEDDED_REPO="git@github.com:openembedded/meta-openembedded.git"
META_RASPBERRYPI_REPO="git@github.com:agherzan/meta-raspberrypi.git"

# Define branches (change if needed)
POKY_BRANCH="scarthgap"  # Set to the desired Yocto release branch
META_OPENEMBEDDED_BRANCH="scarthgap"
META_RASPBERRYPI_BRANCH="scarthgap"

# Directory where the layers will be cloned
YOCTO_DIR="sources"

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$YOCTO_DIR"
cd "$YOCTO_DIR" || exit

# Clone repositories
echo "Cloning Poky..."
git clone -b "$POKY_BRANCH" "$POKY_REPO" || { echo "Failed to clone Poky"; exit 1; }

echo "Cloning meta-openembedded..."
git clone -b "$META_OPENEMBEDDED_BRANCH" "$META_OPENEMBEDDED_REPO" || { echo "Failed to clone meta-openembedded"; exit 1; }

echo "Cloning meta-raspberrypi..."
git clone -b "$META_RASPBERRYPI_BRANCH" "$META_RASPBERRYPI_REPO" || { echo "Failed to clone meta-raspberrypi"; exit 1; }

# Display success message
echo "Repositories cloned successfully into the $YOCTO_DIR directory."