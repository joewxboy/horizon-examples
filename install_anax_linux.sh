#!/bin/bash

OS=`uname -s`
if [ $OS = Darwin ]
    then
        echo "OSX Not Supported.  Please run this script on Linux."
        echo ""
	    exit 1
fi


echo ""
echo "====="
echo "Updating Package Index & Installing Pre-requisites"
echo "====="
echo ""
sleep 2

sudo apt-get -y update
sudo apt-get -y install jq curl make gcc

dver=`docker --version`
echo ""
echo "====="
echo "Installing Docker"
echo "====="
echo ""
sleep 2

USER=`whoami`
if [ $(expr index "$dver" "version") -eq 2 ]
    then
        echo "Docker already installed, skipping."
        echo ""
        sleep 2
    else
        sudo curl -fsSL get.docker.com | sudo sh
fi
if [ $USER != root ]
    then
        sudo usermod -aG docker ${USER}
fi
sudo apt-get -y install docker-compose

hver=`hzn version`
echo ""
echo "====="
echo "Creating Package Entry for Horizon"
echo "====="
echo ""
sleep 2

if [ -s /etc/apt/sources.list.d/bluehorizon.list ]
    then
        echo "Horizon key exists, skipping"
        echo ""
        sleep 2
    else 
        sudo wget -qO - http://pkg.bluehorizon.network/bluehorizon.network-public.key | sudo apt-key add -
aptrepo=updates
        sudo cat <<EOF > /etc/apt/sources.list.d/bluehorizon.list
deb [arch=$(dpkg --print-architecture)] http://pkg.bluehorizon.network/linux/ubuntu xenial-$aptrepo main
deb-src [arch=$(dpkg --print-architecture)] http://pkg.bluehorizon.network/linux/ubuntu xenial-$aptrepo main
EOF
fi

sudo apt-get -y update
sudo apt-get -y install bluehorizon

echo "Horizon installed"
echo ""

hzn version
