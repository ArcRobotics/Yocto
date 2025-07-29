#!/bin/bash
cat << "EOF"
                          /\          /\
                         ( \\        // )
                          \ \\      // /
                           \_\\||||//_/
                            \/ _  _ \
                           \/|(O)(O)|
                          \/ |      |
      ___________________\/  \      /
     //                //     |____|
    //                ||     /      \
   //|                \|     \ 0  0 /
  // \       )         V    / \____/
 //   \     /        (     /    \___________________________________________
//     \   /_________|  |_/     | 										    |
      /  /\   /     |  ||       | I will spice your linux machine BRO!       |
     /  / /  /      \  ||       ---------------------------------------------
     | |  | |        | ||
     | |  | |        | ||
     |_|  |_|        |_||
      \_\  \_\        \_\\
EOF

sudo apt install -y fzf  htop  btop  tree  git  duf  ncdu  unzip curl
sudo apt install -y bzip2 chrpath cpp diffstat g++ gcc lz4 make zstd rpcsvc-proto

#configure git
read -p "Enter git name: " name
git config --global user.name "$name"

read -p "Enter git email: " email
git config --global user.email "$email"

#install oh-my-posh to spice the terminal
export PATH=$PATH:$HOME/.local/bin

echo $PATH

curl -s https://ohmyposh.dev/install.sh | bash -s

#insall cool themes
echo " Installing my theme"

mkdir -p .poshthemes

#silly we mus get the raw files on a public repo
wget -P .poshthemes "https://raw.githubusercontent.com/ArcRobotics/Yocto/refs/heads/master/Helper%20tools/My%20posh%20themes/my-quick-term.omp.json"

echo "My posh is ready to use"

oh-my-posh font install FiraCode

#Uncomment this to get more themes
# wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip
# rm themes.zip

cd

#remove the default bashrc
rm .bashrc

#Downlaod the new bashrc
wget -P . "https://raw.githubusercontent.com/ArcRobotics/Yocto/refs/heads/master/Helper%20tools/.bashrc" --quiet

echo ".bashrc created successfully!"


sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

cd

source .bashrc

ssh-keygen -t rsa && cat ~/.ssh/id_rsa.pub

echo "SSH key created successfully! Please add it to your github account"

rm init_linux_system.sh