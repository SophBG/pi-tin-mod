#!/bin/bash
# Pi Tin "USB mode": exposes the ROM partition to the PC over the USB-C port (USB mass storage).
# Run it from the RetroPie menu (copy to ~/RetroPie/retropiemenu/) while no game is running.
#
# Requirements (see README.md):
#   * config.txt: dtoverlay=dwc2,dr_mode=peripheral   and   gpio=14=ip,pn
#   * the ROMs live on their own FAT32/exFAT partition (ROMPART below), mounted at MNT
#   * TP132/TP133 wired to the Pi Zero 2 W USB D+/D- test pads
ROMPART=/dev/mmcblk0p3
MNT=/home/pi/RetroPie/roms
GPIO=14                                # USB_PWR: high when a USB cable is plugged in

usb_present() {
  if command -v pinctrl >/dev/null; then pinctrl lev $GPIO | grep -q 1
  else raspi-gpio get $GPIO | grep -q "level=1"; fi
}

if ! usb_present; then
  echo "Plug the USB-C cable into a computer first."; sleep 3; exit 1
fi
echo "Entering USB mode..."
sync
sudo umount "$MNT" || { echo "ROM partition busy - close everything and try again"; sleep 3; exit 1; }
sudo modprobe g_mass_storage file="$ROMPART" removable=1 stall=0 ro=0
echo "USB mode active. Unplug the cable (after ejecting on the PC) to return."
while usb_present; do sleep 1; done
sudo modprobe -r g_mass_storage
sudo fsck -a "$ROMPART" >/dev/null 2>&1
sudo mount "$MNT"
echo "Back to normal mode."
sleep 2
