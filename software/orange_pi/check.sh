#!/bin/bash
# Pi Tin on an Orange Pi Zero 2W: checks that each part of the overlay came up after install.sh
# and a reboot. With --test it also dims the screen, lights the LEDs, plays a sound and echoes
# button presses.
#     ./check.sh            # status only
#     sudo ./check.sh --test

ok()  { printf '  ok    %s\n' "$*"; }
bad() { printf '  FAIL  %s\n' "$*"; FAILED=1; }
FAILED=0
. /etc/default/pitin 2>/dev/null

echo "Pi Tin check"
[ -d /proc/device-tree/pitin-gamepad ] && ok "overlay loaded" || bad "overlay not loaded (user_overlays=pitin in /boot/armbianEnv.txt?)"

if grep -qs mi0283qt /sys/class/drm/card*/device/uevent; then ok "display driver (mi0283qt)"
else bad "display driver: modinfo mi0283qt; dmesg | grep -i -e spi -e mi0283qt"; fi

BL=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n 1)
[ -n "$BL" ] && ok "backlight PWM ($(basename "$BL"), brightness $(cat "$BL/brightness")/$(cat "$BL/max_brightness"))" \
	|| bad "no backlight: dmesg | grep -i -e pwm -e backlight"

ls /dev/spidev*.1 >/dev/null 2>&1 && ok "LED SPI device $(ls /dev/spidev*.1 | head -n 1)" || bad "no /dev/spidev*.1 for the LEDs"

if aplay -l 2>/dev/null | grep -qi pitin; then ok "sound card pitin"
else bad "no sound card 'pitin': dmesg | grep -i -e ahub -e snd"; fi

INPUTS=$(python3 -c 'import evdev; print("\n".join(evdev.InputDevice(p).name for p in evdev.list_devices()))' 2>/dev/null)
grep -qx 'Pi Tin Gamepad' <<<"$INPUTS" && ok "gamepad buttons" || bad "no 'Pi Tin Gamepad' input device"
grep -qx 'Pi Tin System' <<<"$INPUTS" && ok "power button and USB detect" || bad "no 'Pi Tin System' input device"

ls /sys/bus/platform/drivers/poweroff-gpio/ 2>/dev/null | grep -q pitin && ok "power-off line (pin 5)" || bad "gpio-poweroff not bound: the board would stay on after shutdown"

ls /sys/class/udc/ 2>/dev/null | grep -q . && ok "USB device controller $(ls /sys/class/udc | head -n 1)" || bad "no USB device controller (USB-drive mode)"
mountpoint -q "${ROM_MOUNT:-/nonexistent}" && ok "ROM drive mounted on $ROM_MOUNT" || bad "ROM drive not mounted"
for s in pitin-retroarch pitin-usbd pitin-daemon; do
	systemctl is-active -q "$s" && ok "service $s" || bad "service $s: journalctl -u $s"
done
echo "  settings page: http://$(hostname -I 2>/dev/null | cut -d' ' -f1):${WEB_PORT:-8080}"

if [ "${1:-}" = --test ]; then
	[ "$(id -u)" = 0 ] || { echo "--test needs sudo"; exit 1; }
	systemctl stop pitin-retroarch pitin-daemon     # free the sound card and the LEDs
	if [ -n "$BL" ]; then
		echo; echo "Backlight: 20 % for 2 s"
		echo $(( $(cat "$BL/max_brightness") / 5 )) >"$BL/brightness"; sleep 2
		cat "$BL/max_brightness" >"$BL/brightness"
	fi
	echo "LEDs: rainbow for 3 s"
	timeout -s INT 3 /usr/local/bin/pitin-leds demo; /usr/local/bin/pitin-leds off
	echo "Sound: one round of front-left / front-right"
	speaker-test -c 2 -t wav -l 1 >/dev/null 2>&1 || echo "  speaker-test failed"
	echo "Buttons: press them (15 s)"
	timeout 15 python3 - <<'EOF'
import evdev, select
devs = [evdev.InputDevice(p) for p in evdev.list_devices()]
devs = {d.fd: d for d in devs if d.name.startswith('Pi Tin')}
while True:
    for fd in select.select(devs, [], [])[0]:
        for ev in devs[fd].read():
            if ev.type in (evdev.ecodes.EV_KEY, evdev.ecodes.EV_SW) and ev.value in (0, 1):
                name = evdev.ecodes.bytype[ev.type][ev.code]
                print('  ', devs[fd].name, name if isinstance(name, str) else name[0], 'down' if ev.value else 'up', flush=True)
EOF
	systemctl start pitin-daemon pitin-retroarch    # the daemon restores the saved brightness
fi
exit $FAILED
