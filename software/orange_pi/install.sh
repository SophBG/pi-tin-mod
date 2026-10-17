#!/bin/bash
# Pi Tin on an Orange Pi Zero 2W: installs everything on a fresh Armbian (Debian, "current"
# sunxi kernel; DietPi on the same kernel also works). Run from this folder, as your normal user:
#
#     sudo ./install.sh                 # ROM drive of 4 GB
#     sudo ROM_SIZE=16G ./install.sh    # bigger ROM drive
#
# Then reboot. Safe to run again (it updates the files and keeps the ROM drive).
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
U=${PITIN_USER:-${SUDO_USER:-}}
ROM_SIZE=${ROM_SIZE:-4G}

die() { echo "error: $*" >&2; exit 1; }
step() { echo; echo "== $*"; }

[ "$(id -u)" = 0 ] || die "run it with sudo"
[ -n "$U" ] && [ "$U" != root ] || die "run it with sudo from your normal user (or set PITIN_USER=name)"
H=$(getent passwd "$U" | cut -d: -f6)
[ -d "$H" ] || die "no home folder for $U"

ENV=/boot/armbianEnv.txt
[ -f "$ENV" ] || ENV=/boot/dietpiEnv.txt
[ -f "$ENV" ] || die "no /boot/armbianEnv.txt: this script expects Armbian or DietPi"
grep -aqiE 'zero ?2w' /proc/device-tree/model 2>/dev/null \
	|| echo "warning: this does not look like an Orange Pi Zero 2W ($(tr -d '\0' </proc/device-tree/model))"

step "packages"
apt-get update
apt-get install -y device-tree-compiler python3-spidev python3-evdev alsa-utils dosfstools \
	retroarch libretro-core-info
for p in libretro-nestopia libretro-gambatte libretro-mgba libretro-snes9x libretro-genesisplusgx \
	libretro-beetle-pce-fast libretro-beetle-psx libretro-desmume; do
	apt-get install -y "$p" || echo "   (skipped $p: not in the package lists)"
done

RETROARCH=$(command -v retroarch)
if ! "$RETROARCH" --features 2>/dev/null | grep -qiE 'kms.*(yes|true)'; then
	step "RetroArch from the package lists has no KMS support: building it (about 30 minutes)"
	apt-get install -y git build-essential pkg-config libasound2-dev libudev-dev libdrm-dev \
		libgbm-dev libegl-dev libgles-dev libfreetype-dev zlib1g-dev
	TAG=$(git ls-remote --tags --refs https://github.com/libretro/RetroArch.git 'v1.*' \
		| sed 's#.*/##' | sort -V | tail -n 1)
	SRC=/usr/local/src/RetroArch
	rm -rf "${SRC:?}"
	git clone --depth 1 --branch "$TAG" https://github.com/libretro/RetroArch.git "$SRC"
	(cd "$SRC" && ./configure --prefix=/usr/local --disable-x11 --disable-wayland --disable-qt \
		--disable-pulse --disable-sdl2 --disable-opengl1 --enable-kms --enable-egl \
		--enable-opengles --enable-opengles3 --enable-udev --enable-alsa \
		&& make -j"$(nproc)" && make install)
	RETROARCH=/usr/local/bin/retroarch
fi

step "device-tree overlay (display, backlight, LEDs, sound, buttons, power)"
mkdir -p /boot/overlay-user
dtc -@ -q -I dts -O dtb -o /boot/overlay-user/pitin.dtbo "$HERE/pitin-opi-zero2w.dts"
# U-Boot drops an overlay that does not apply, so test it on the board's device tree first.
DTB=/boot/dtb/$(sed -n 's/^fdtfile=//p' "$ENV" | tail -n 1)
if [ -f "$DTB" ]; then
	TMP=$(mktemp)
	fdtoverlay -i "$DTB" -o "$TMP" /boot/overlay-user/pitin.dtbo \
		|| { rm -f "$TMP"; die "the overlay does not apply to $DTB: it needs Armbian's sunxi kernel (H616 PWM and audio nodes)"; }
	rm -f "$TMP"
else
	echo "warning: could not find the board's .dtb to test the overlay (fdtfile= in $ENV)"
fi
if grep -q '^user_overlays=' "$ENV"; then
	grep -qE '^user_overlays=(.* )?pitin( |$)' "$ENV" || sed -i 's/^user_overlays=\(.*\)$/user_overlays=\1 pitin/' "$ENV"
else
	echo 'user_overlays=pitin' >>"$ENV"
fi
# Pins 8/10 carry the serial console on this board; the Pi Tin uses them for USB detect and RIGHT.
if grep -q '^console=' "$ENV"; then sed -i 's/^console=.*/console=display/' "$ENV"; else echo 'console=display' >>"$ENV"; fi
systemctl disable --now serial-getty@ttyS0.service 2>/dev/null || true

step "programs and settings"
install -d /etc/pitin/autoconfig
install -D -m 755 "$HERE/pitin_leds.py" /usr/local/lib/pitin/pitin_leds.py
ln -sf /usr/local/lib/pitin/pitin_leds.py /usr/local/bin/pitin-leds
install -m 644 "$HERE/pitin-web.html" /usr/local/lib/pitin/pitin-web.html
install -m 755 "$HERE/pitin-daemon" /usr/local/bin/pitin-daemon
install -m 755 "$HERE/pitin-usbd" /usr/local/bin/pitin-usbd
install -m 644 "$HERE/asound.conf" /etc/asound.conf
install -m 644 "$HERE/retroarch-pitin.cfg" /etc/pitin/retroarch-pitin.cfg
install -m 644 "$HERE/autoconfig/Pi Tin Gamepad.cfg" "/etc/pitin/autoconfig/Pi Tin Gamepad.cfg"
usermod -aG video,render,input,audio "$U"

step "ROM drive ($ROM_SIZE FAT32 image, mounted on $H/roms)"
IMG="$H/roms.img"
MNT="$H/roms"
if [ ! -e "$IMG" ]; then
	fallocate -l "$ROM_SIZE" "$IMG"
	mkfs.vfat -F 32 -n PITINROMS "$IMG"
fi
chown "$U": "$IMG"
install -d -o "$U" -g "$(id -gn "$U")" "$MNT"
grep -qF " $MNT vfat " /etc/fstab \
	|| echo "$IMG $MNT vfat loop,uid=$(id -u "$U"),gid=$(id -g "$U"),umask=0022,nofail 0 0" >>/etc/fstab
mountpoint -q "$MNT" || mount "$MNT"
# One folder per console (the settings page sorts uploads into them by file type).
for d in gb gbc gba nes snes megadrive mastersystem gamegear pcengine psx nds; do mkdir -p "$MNT/$d"; done
OLD_PW=$(sed -n 's/^WEB_PASSWORD=//p' /etc/default/pitin 2>/dev/null || true)
OLD_LANG=$(sed -n 's/^LANGUAGE=//p' /etc/default/pitin 2>/dev/null || true)
cat >/etc/default/pitin <<EOF
ROM_IMAGE=$IMG
ROM_MOUNT=$MNT
USB_MODE=auto
WEB_PORT=8080
# Password for the settings page (any user name); empty = no password.
WEB_PASSWORD=$OLD_PW
# Language of the on-screen messages and the hotkey list: en or fr; empty = the system's language.
LANGUAGE=$OLD_LANG
EOF
# The hotkey list for SPECIAL + SELECT (a RetroArch overlay card), in the console's language.
L=$OLD_LANG
case "$L" in
	en|fr) ;;
	*) case "$(sed -n 's/^LANG=//p' /etc/default/locale 2>/dev/null | tr -d '"')" in fr*) L=fr ;; *) L=en ;; esac ;;
esac
install -d /etc/pitin/overlay
install -m 644 "$HERE/overlay/help-card-$L.png" /etc/pitin/overlay/card.png
install -m 644 "$HERE/overlay/pitin-menu.cfg" /etc/pitin/overlay/pitin-menu.cfg

step "services"
sed -e "s|@USER@|$U|g" -e "s|@HOME@|$H|g" -e "s|@RETROARCH@|$RETROARCH|g" \
	"$HERE/pitin-retroarch.service" >/etc/systemd/system/pitin-retroarch.service
install -m 644 "$HERE/pitin-usbd.service" /etc/systemd/system/pitin-usbd.service
install -m 644 "$HERE/pitin-daemon.service" /etc/systemd/system/pitin-daemon.service
systemctl daemon-reload
systemctl disable getty@tty1.service 2>/dev/null || true
systemctl enable pitin-retroarch.service pitin-usbd.service pitin-daemon.service

step "done"
echo "Reboot to load the overlay: sudo reboot"
echo "After the reboot, check the hardware with: $HERE/check.sh"
echo "LED and brightness settings page: http://$(hostname -I 2>/dev/null | cut -d' ' -f1):8080"
