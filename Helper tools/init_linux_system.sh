#!/bin/bash

if [ "$1" != "sudo" ]; then
	echo "Please run this script with sudo."
else
	return 0
fi
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

apt install -y fzf  htop  btop  tree  git  duf  ncdu  unzip
apt install -y bzip2 chrpath cpp diffstat g++ gcc lz4 make zstd rpcsvc-proto

#configure git
git config user.name --gloable "omar al rafei"
git config user.email  --gloable "omaralrafei.95@gmail.com"

#install oh-my-posh to spice the terminal
curl -s https://ohmyposh.dev/install.sh | bash -s

#insall cool themes
echo " Installing my theme"

mkdir -p ~/.poshthemes
wget -P ~/.poshthemes "https://github.com/ArcRobotics/Yocto/blob/master/Helper%20tools/My%20posh%20themes/my-quick-term.omp.json" --quiet

echo "My posh is ready to use"

#Uncomment this to get more themes
# wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip
# rm themes.zip

#remove the default bashrc
rm ~/.bashrc

#Downlaod the new bashrc
wget "https://github.com/ArcRobotics/Yocto/blob/master/Helper%20tools/.bashrc" --quiet

echo ".bashrc created successfully!"

source ~/.bashrc

#ssh-keygen -t rsa && cat ~/.ssh/id_rsa.pub

rm init_linux_system.sh