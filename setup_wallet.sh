#!/bin/bash


TMP_FOLDER=$(mktemp -d)
WALLET_URL="https://github.com/Stipend-Developer/stipend/releases/download/1.0.7/stipend-linux-1.0.9.zip"
WALLET_ARCH="stipend-linux-1.0.9.zip"
WALLET_DIR="/root/Desktop"
WGET="/usr/bin/wget"

function prepare_swap() {
	if free | awk '/^Swap:/ {exit !$2}'; then
		printf "\nSwap exists"
	else
		dd if=/dev/zero of=/swapfile count=2048 bs=1M
		chmod 600 /swapfile
		mkswap /swapfile
		swapon /swapfile
		echo "/swapfile none swap sw 0 0" >> /etc/fstab
	fi
}

function update_system() {
	apt-get -y update
}

function install_packages() {
apt-get -yq install lubuntu-core
apt-get -yq install lxterminal
apt-get -yq install xarchiver
apt-get -yq install firefox
apt-get -yq install libdb5.3++
apt-get -yq install libboost-all-dev
apt-get -yq install qtbase5-dev
apt-get -yq install libminiupnpc-dev
}

function create_xorg() {
	touch /usr/share/X11/xorg.conf.d/xorg.conf
	cat > /usr/share/X11/xorg.conf.d/xorg.conf << EOL

	Section "Device"
		Identifier      "device"
	EndSection

	Section "Screen"
		Identifier      "screen"
		Device          "device"
		Monitor         "monitor"
		DefaultDepth    24

		SubSection "Display"
			Modes       "1280x800" "1280x1024" "1280x960" "1280x768" "1280x720" "1024x768" "800x600"
		EndSubSection

	EndSection

	Section "Monitor"
		Identifier      "monitor"
		HorizSync       0.0 - 100.0
		VertRefresh     0.0 - 100.0
	EndSection

	Section "ServerLayout"
		Identifier      "layout"
		Screen          "screen"
	EndSection
EOL
}

function install_wallet() {
	cd $TMP_FOLDER
	$WGET $WALLET_URL
	mkdir $WALLET_DIR
	mkdir $WALLET_DIR
	unzip $WALLET_ARCH -d $WALLET_DIR
}

function enable_autologin() {
touch /etc/lightdm/lightdm.conf
cat > /etc/lightdm/lightdm.conf << EOL
[SeatDefaults]
autologin-user=root
autologin-user-timeout=0
user-session=ubuntu
EOL
}



#***************************** main *********************************************************

printf "\nPlease wait for startup script to finish and login window to appear.\nIt can take serveral minutes - be patient!"  > /dev/tty1

printf "\n\nCreating and turning on SWAP" > /dev/tty1
prepare_swap

printf "\n\nInstalling updates" > /dev/tty1
update_system

printf "\n\nDownloading and installing required packages\n" > /dev/tty1
install_packages

printf "\n\nCreate proper xorg.conf for X" > /dev/tty1
create_xorg

printf "\n\nDownloading and installing SPD wallet" > /dev/tty1
install_wallet
enable_autologin

systemctl start lightdm
