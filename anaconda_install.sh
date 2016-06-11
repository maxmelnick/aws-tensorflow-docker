#!/usr/bin/env bash

start_seconds="$(date +%s)"
echo "Welcome to the initialization script."

ping_result="$(ping -c 2 8.8.4.4 2>&1)"
if [[ $ping_result != *bytes?from* ]]; then
    echo "Network connection unavailable. Try again later."
    exit 1
fi

# install git
apt_packages=(
    git
)

sudo apt-get update
sudo apt-get upgrade

echo "Installing apt-get packages..."
sudo apt-get install -y ${apt_packages[@]}
sudo apt-get clean

#install anaconda
anaconda=Anaconda2-4.0.0-Linux-x86_64.sh
cd ~
if [ ! -f $anaconda ]
	then
		echo "No Anaconda install file pre-loaded. Downloading Anaconda"
		echo "NOTE: downloading and installing Anaconda2-4.0.0-Linux-x86_64.sh"
    	wget --quiet http://repo.continuum.io/archive/$anaconda
fi
chmod +x $anaconda

sudo ./$anaconda -b -p /opt/anaconda

conda_path=/opt/anaconda/bin
echo $conda_path

cat >> ~/.bashrc << END
PATH=:$conda_path:\$PATH
END