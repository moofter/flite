# Flite
A minimal Fedora workstation thingy.
![Flite](https://github.com/moofter/flite/blob/main/desktop.png?raw=true)
Aim of this repo is to educate myself on creating custom fedora iso's to install offline locally on multiple machines and have all I need included on it. I like a minimal install but also have some quality of life stuff and easy to use utilities that Gnome provides. After removing some left overs the installed system takes up about 1.9GB of disk space and has less than 1100 packages installed. This can be trimmed down further by removing fonts and locales and such.

The iso avaiable for download was build using the ```flite.ks``` kickstart file. It includes my selection of packages and apps. A list of all thats included can be found below. You can use the iso as is or even better; build your own iso! I've provided instructions below.

If you choose to use the iso keep in mind it only has Intel graphical drivers preinstalled for integrated graphics up to 5th gen as thats the main target for my usage. If you have 6th gen or newer simply install ```intel-media-driver``` and remove the ```libva-intel-driver``` and reboot.

A small Webkit based browser called Epiphany (```Web```) is included but ```flatpack``` is installed to add your favourite browser and ```flatseal``` is available to manage installed flatpak permissions. Of course it is also possible to quickly install a browser like this; ```dnf -y install firefox``` ☺️

When not using custom partitioning Fedora defaults to using btrfs. This is my preferred option due to snapshots. If you don't want this setup partitions manually using the "custom" or "advanced custom" options in the installer. You can also use gparted to set things up and then assign mount points using the "custom" option in the installer.

**You can do a full offline installation with the iso or iso's created with the kickstart!**

## Index
* [Features](#features)
* [Installation](#installation)
* [Post install](#post-install)
* [Troubleshooting](#troubleshooting)
* [Updating](#updating)
* [AMD/NV](#amdnv)
* [Firefox](#firefox)
* [Todo](#todo)

## Features
* Included packages:
  - GUI Stuff:
    - Gnome 44 on Wayland or Xorg
    - Console
    - Disk Usage
    - Disk Utility
    - Document Viewer
    - Emoji Picker
    - Extensions
    - File Manager (nautilus)
    - Flatseal
    - Font Viewer
    - Image Viewer
    - Logs
    - Media Player (mpv)
    - Settings
    - Software Centre
    - System Monitor
    - Text Editor
    - Timeshift
    - Tweaks
    - Weather
  - Misc GUI related:
    - Gnome Browser Connector (needed to install extensions from Gnome's official site)
    - Plymouth + Spinner theme
    - Shell extension: Caffeine
    - Shell extension: Dash-to-dock
    - Shell extension: Just Perfection
  - Shell Utils:
    - acpi deamon and tools
    - axel
    - bat 🦀
    - btop
    - exa 🦀
    - htop
    - igt-gpu-tools
    - nano :)
    - ripgrep 🦀
    - wget
    - zsh
    - zsh suggestions
    - zsh syntax highlight
  - Driver Stuff:
    - ffmpeg-free
    - libva-intel-driver
    - libva-utils
    - libvacodecs

# Installation
Download the iso and install as usual or to build your own customised version follow the instructions below. You will need a working Fedora or RHEL based system.
```
sudo setenforce 0
sudo dnf install mock
sudo usermod -a -G mock $USER
```
Unless you're doing this as root, please logout and log back in.
```
mock -r fedora-38-x86_64 --init
mock -r fedora-38-x86_64 --install lorax-lmc-novirt nano pykickstart wget
mock -r fedora-38-x86_64 --shell --old-chroot --enable-network
```
Now we're inside the mock environment. Time to build the iso. Use wget to grab the kickstart file from the repo or create a flite.ks file with nano and paste the contents of the kickstart file manually.
```
wget https://raw.githubusercontent.com/moofter/flite/main/flite.ks
# edit the kickstart file to taste, it is safe to add/remove packages in the section I've added
nano flite.ks
# flatten the kickstarter file
ksflatten --config flite.ks -o flat.ks
```
Start the building process.
```
livemedia-creator --ks flat.ks --no-virt --resultdir /var/lmc --project Flite --make-iso --volid Flite --iso-only --iso-name Flite-38-x86_64.iso --releasever 38 --macboot
```
Exit the mock environment and move the iso to the current directory.
```
sudo mv /var/lib/mock/fedora-38-x86_64/root/var/lmc/Flite-38-x86_64.iso .
```
Clean up whatever mess mock has made.
```
mock -r fedora-38-x86_64 --scrub=all
```
Write the iso to a usb stick using cat, cp, etcher or even Fedora's own tool. You know how it goes!

## Post install
If you install software using the Gnome software-centre make sure you select the source you want to install from. It defaults to flatpak when available but many apps you can also installed from the Fedora repo. Only use the Flatpak version if you need to as they take up a lot more space.

### Remove left overs.
```
sudo dnf remove anaconda\*
```
Optionally if you just want to use ```dnf``` remove flatpak, flatseal and gnome-software.
```
sudo dnf remove flatpak\* flatseal
```
Optionally remove some unused firmware packages (see ```dnf list installed | grep firmware```).
```
sudo dnf remove amd-gpu-firmware nvidia-gpu-firmware
```
### Verify SELinux mode
SELinux should be enabled by default and running in ```enforcing``` mode. You can get some information about the current SELinux status with the ```sudo sestatus``` command. If its enabled but not running in enforcement mode (```Current mode: permissive```) run the following commands to enable it, or disable in the section after it. 
```
# get current status, should be enabled but in permissive mode
sudo sestatus
# relabel files on next boot, this should fully enable selinux
sudo fixfiles onboot
# and reoobt
reboot
```
After relabeling check the status again and if you see ```Current mode: enforcing``` then SELinux is fully functional now. Instead of ```sestatus``` you can also use ```getenforce``` to quikly see the enforcement mode.

Disabling SELinux completely is not recommened by Fedora, who wants us to use permissive mode in ```/etc/selinux/config``` instead. But if you want to disable it then run ```sudo grubby --update-kernel ALL --args selinux=0``` then reboot and no SELinux stuff will be loaded or used at all.

Important to note that SELinux may block things you wish to unblock. So every now and then or when something seems broken or not working properly check for any SELinux denials. As opart of troubleshooting you can also temporarly disable SELinux by using the grubby command above and when you want to turn it back on just run these commands:
```
sudo grubby --update-kernel ALL --remove-args selinux
sudo fixfiles onboot
sudo reboot
```
### Sorting apps
To sort apps alphabetically, run as your normal user account:
```
gsettings set org.gnome.shell app-picker-layout "[]"
```
## Enable remote ssh access
If you need remote ssh access now is the time to enable it:
```
sudo systemctl enable --now sshd
```
### Enable Secure Boot
Secure Boot can also be enabled in your bios now, if your machine supports it.

### ui tweaks
Open the ```Extensions``` app and enable the 3 builtin extensions to get sleep prevention, a fixed dash and a bunch of extra options to configure the interface. You can configure each of them to your liking or simply disable or remove them (```dnf list installed | grep gnome-shell-extension```). there are many more extensions both in the Fedora repo and plenty more on the [Gnome extension website](https://extensions.gnome.org). To use the latter you need to install an add-on in Firefox. The site will prompt you for it. Of course this step is completely optional and the extensions can be removed if you don't need them.

# Troubleshooting
## Auto login issues
Sometimes auto login can't seem to be enabled using the gui interface, this seems to be fixed by Fedora now. It can be enabled manually if the toggle isn't working for you. Edit ```/etc/gdm/custom.conf``` and in the ```[daemon]``` section add the following two lines:
```
AutomaticLoginEnable=true
AutomaticLogin=moofter
```

## Timeshift errors
In order for Timeshift to work properly we have to rename the root and home subvolumes. For some strange reason Ubuntu who made this great tool has hardcoded those names. Also Fedora didn't fix this in their own package which is kind of odd given it is in their repo and Fedora defaults to using btrfs. If you don't plan on using filesystem snapshots consider removing it; ```dnf remove timeshift```.
```
# gather some information
sudo lsblk
sudo blkid

# mount to temporary location, device path is that of your installation disk:
# /dev/sda3 in most cases of default or /dev/mapper/luks-uuid for encrypted installs
# 
sudo mkdir /btrfs_rename
sudo mount -o subvolid=5 /dev/mapper/luks-long-string /btrfs_rename
# the actual renaming
sudo mv /btrfs_rename/root /btrfs_rename/@
sudo mv /btrfs_rename/home /btrfs_rename/@home
# final check
sudo btrfs subvolume list /btrfs_rename
```
Now let's update ```/etc/fstab```, change the ```subvol=``` parts to have the new names. You can also add additional mount option while you're here. I like to add ```noatime``` as it can speed up the filesystem a bit. Other options that might be of interest are ```ssd``` and ```discard=async```.
```
cat /etc/fstab
#
# /etc/fstab
# Created by anaconda on Thu Apr 20 18:44:54 2023
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
UUID=35eca94c-dc1a-4e88-8638-b4174fa0a5eb /                       btrfs   subvol=@,noatime,compress=zstd:1 0 0
UUID=cadc01d8-5958-473c-b267-075a2e86c2e6 /boot                   ext4    defaults        1 2
UUID=35eca94c-dc1a-4e88-8638-b4174fa0a5eb /home                   btrfs   subvol=@home,noatime,compress=zstd:1 0 0
```
We need to [update the grub config](https://fedoraproject.org/wiki/GRUB_2#Updating_the_GRUB_configuration_file) and reboot the system and try out Timeshift.
```
sudo grub2-mkconfig -o /etc/grub2.cfg
sudo grub2-mkconfig -o /etc/grub2-efi.cfg
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
Reboot!

## Sleep/wake issues on some Macs and maybe others
You may want to disable sleep and suspending all together for server usage and such:
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```
If your system doesn't wake up or wakes up only after 5-10 minutes there are several thigns to try and fix it.

First make sure the ```acpid``` service is enabled and running:
```
systemctl enable --now acpid
```
Now reboot and test sleep. If it works, great! If not try disabling hiberation and hybrid sleep:
```
sudo systemctl mask hibernate.target hybrid-sleep.target
```
We also need to edit ```/etc/systemd/sleep.conf``` and make some changes, find these values and edit them like so:
```
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
SuspendState=mem 
```
Reboot and test again, if it's still not working then we're out of options and you will need to seek guidance at the Fedora forums.

You want to change what some of the buttons available to you do. This can be done by editing ```/etc/systemd/logind.conf``` and changing the following:
```
HandlePowerKey=suspend
HandleHibernateKey=suspend
HandleLidSwitch=suspend
```
Please note it is possible the power or other buttons are still mapped to try and hibernate instead of suspend. What happens when you press power (related) buttons is also defined in ```/etc/systemd/logind.conf```. Just search for the word hibernate in that file. A valid option is also ```ignore``` if you want nothing to happen when pressing that key.

## sync/match login screen (gdm)
If you've changed resolution or other screen settings and what them applied in the login screen as well execute the following command:
```
sudo cp ~/.config/monitors.xml /var/lib/gdm/.config/
```

# Updating
Easy mode!
```
dnf update
```

# AMD/NV
If you have an AMD/NV graphics card it should be possible to boot and install but you'll manually have to setup drivers and such.

https://rpmfusion.org/Howto/Multimedia

https://rpmfusion.org/Howto/NVIDIA

# Firefox

https://fedoraproject.org/wiki/Firefox_Hardware_acceleration#Video_decoding

https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin

https://addons.mozilla.org/en-US/firefox/addon/enhanced-h264ify

## Todo
+ This list will be populated when I sorted out my draft todo list
