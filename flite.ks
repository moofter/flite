# flite.ks -- A minimal Fedora kickstarter
# Most options should speak for itself but I also added some comments here and there.
# NOTE: This file must be flattened before use: ksflatten --config flite.ks -o flat.ks

# These are just the defaults used on the live image, the language, keyboard layout, etc can be changed in the installer as usual.
timezone Europe/Amsterdam --utc
keyboard --vckeymap=us --xlayouts='us'
lang en_GB.UTF-8
firewall --enabled --service=mdns
network  --bootproto=dhcp --device=link --activate
shutdown
rootpw --iscrypted --lock locked
selinux --enforcing
services --disabled="sshd" --enabled="NetworkManager"
xconfig  --startxonboot
bootloader --location=none
zerombr
clearpart --all
part / --fstype="ext4" --size=5120

# Standard repo's
repo --name="fedora" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name="updates" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
repo --name="fedora-cisco-openh264" --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-cisco-openh264-$releasever&arch=$basearch
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch"
# Fusion repo's
repo --name="rpmfusion-free" --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch
repo --name="rpmfusion-free-updates" --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree" --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree-updates" --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch

# This block does what was in the base kickstarter, I added starting up the acpid and thermald services.
%post
systemctl enable --now acpid
systemctl enable --now thermald
systemctl enable tmp.mount
cat >> /etc/fstab << EOF
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF
rm -f /var/lib/rpm/__db*
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' |sort -rn
rm -f /var/lib/rpm/__db*
/usr/bin/mandb
rm -f /core*
rm -f /var/lib/systemd/random-seed
echo 'File created by kickstart. See systemd-update-done.service(8).' \
    | tee /etc/.updated >/var/.updated
rm -f /boot/*-rescue*
/sbin/chkconfig network off
rm -f /etc/machine-id
touch /etc/machine-id
sed -i 's/^livesys_session=.*/livesys_session="gnome"/' /etc/sysconfig/livesys
%end

# This block sets the default plymouth theme and rids us of the gnome-tour. Somehow removing it with "-gnome-tour" in the packages section doesn't work.
%post
dnf remove -y gnome-tour
plymouth-set-default-theme spinner -R
%end

# Packages, don't edit the first few, start editing below the explanation comment.
%packages
@^minimal-environment
@anaconda-tools
aajohan-comfortaa-fonts
anaconda
anaconda-install-env-deps
anaconda-live
dracut-live
grub2-efi-x64
grub2-efi-x64-cdboot
grub2-efi-x64-modules
kernel
kernel-modules
kernel-modules-extra
livesys-scripts
rpmfusion-free-release
rpmfusion-nonfree-release

#
# Here's where you likely want to make your edits. Add more packages, remove some, add firmware and drivers.
# For example if you have Intel grapics 6th gen or newer replace "libva-intel-driver" with "intel-media-driver".
# Refer to the Fedora wiki to find out what kind of drivers and utils your hardware needs.
# Once installed you can safely remove anaconda with "dnf remove anaconda\*" to tidy things up.
# If you don't know what something is look it up using "dnf" or a search engine and see if you need or want it.
# If you need acpi to work "properly" then post-install "systemctl enable --now acpid" has to be run. I don't know why its not autostarted by default.
#

# acpi stuff
acpi
acpid
acpitool

# CLI stuff
axel
bat
btop
exa
htop
igt-gpu-tools
nano
pciutils
ripgrep
unzip
usbutils
wget

# some zsh stuff, because it is the best shell, fight me
zsh
zsh-autosuggestions
zsh-syntax-highlighting

# Gnome stuff
# If you want a bare bones Gnome install only install "gdm", "gnome-console" and "gnome-session-wayland-session" and remove the rest.
# Maybe keep nautilus unless you want to install another file manager or are a masochist who uses a terminal file manager =]
# If you want to install Gnome extensions using a browser you must also keep the "gnome-browser-connector" package.
# You could remove everything below and for example just add a core (or meta for all the bloat) xfce package or kde, or anythign else available in Fedora or rpmfusion repo's.
baobab
emoji-picker
eog
epiphany
evince
#file-roller
gdm
gnome-browser-connector
gnome-console
gnome-disk-utility
gnome-extensions-app
gnome-font-viewer
gnome-keyring
gnome-logs
gnome-session-wayland-session
gnome-shell-extension-caffeine
gnome-shell-extension-dash-to-dock
gnome-shell-extension-just-perfection
gnome-software
gnome-system-monitor
gnome-text-editor
gnome-tweaks
gnome-weather
nautilus

# GUI stuff
flatseal
timeshift
mpv

# Drivers/misc
#broadcom-wl
ffmpeg-free
#iwl7260-firmware
libavcodec-freeworld
libva-utils
thermald

# Intel graphics, use intel-media-driver for 6th gen and later
libva-intel-driver
#intel-media-driver

# Totally optional, add plymouth + plain spinner theme. If you remove this also remove the "plymouth-set-default-theme spinner -R" command above.
plymouth
plymouth-theme-spinner

# glibc lang packas, need to test if this can be removed or not
glibc-all-langpacks

# Please leave the removals below this line in tact unless you really need something from it.
-@dial-up
-@input-methods
-@standard
-device-mapper-multipath
-fcoe-utils
-gfs2-utils
-reiserfs-utils
%end
