#!/bin/bash

#This init the build enviroment and add layers to bitbake layers

#source the build enviroment
source sources/poky/oe-init-build-env

#return back one step as sourcing automatically put us in build directory
cd ..
echo ""

#Add any extra layer that should be included here
echo "Adding sources/meta-openembedded/meta-oe/"
echo ""
bitbake-layers add-layer sources/meta-openembedded/meta-oe/

echo "Adding sources/meta-openembedded/meta-python/"
echo ""
bitbake-layers add-layer sources/meta-openembedded/meta-python/

echo "Adding sources/meta-openembedded/meta-networking/"
echo ""
bitbake-layers add-layer sources/meta-openembedded/meta-networking/

echo "Adding sources/meta-openembedded/meta-multimedia/"
echo ""
bitbake-layers add-layer sources/meta-openembedded/meta-multimedia/

echo "Adding sources/meta-openembedded/meta-raspberrypi/"
echo ""
bitbake-layers add-layer sources/meta-raspberrypi/

#Command to show the layers for verfication
bitbake-layers show-layers