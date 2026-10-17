# Pi Tin mod

Personal build of jackw01's [Pi Tin](https://github.com/jackw01/pi-tin) (3D-printed clamshell version, KiCad 10). It adds 10 RGB LEDs under the buttons, a centred speaker, a USB-drive mode for the ROMs, and ESD protection on USB, and runs on an Orange Pi Zero 2W. The upstream [build guides](https://jackw01.github.io/pi-tin/) still apply. License: CERN-OHL-W v2.

## Boards

| | Main | Display |
|---|---|---|
| Size | 89.15 × 55.65 mm | 39.15 × 46.15 mm |
| **Thickness** | **1.0 mm** | **0.6 mm** |
| Layers, copper | 2, 1 oz | 2, 1 oz |
| Min. track / hole / via | 0.2 / 0.3 / 0.6 mm | 0.2 / 0.3 / 0.6 mm |

Gerbers for both boards are in `fab/`.

## Main board changes

| Function | Parts | Notes |
|---|---|---|
| RGB LEDs | D1–D10 (WS2812B-2020) | Chain: D1 → D10. D1–D4 ABXY, D5 Start, D6 Select, D7–D10 D-pad. |
| LED driver | U106 74AHCT1G125, R130 330 Ω | Input: SPI MOSI. Enabled only by the second SPI chip select on header pin 21, so the display (first chip select) never reaches the LEDs. |
| | R131 10 k, R132 100 k | R131: buffer off at boot. R132: data line low. |
| USB detect | R133/R134 100 k | VBUS divider to header pin 8 |
| USB-drive mode | U107 USBLC6-2SC6, TP132 (D+), TP133 (D−) | Wire TP132/TP133 by hand to the Orange Pi's USB D+/D− (see Hardware notes). Optional. |
| Backlight PWM | Header pins 16 and 18 swapped | Backlight on pin 16, UP on pin 18 (upstream: the other way round). Pin 16 is a hardware PWM on the Orange Pi. |

**Footprints for both suppliers:**
- **J101:** HCTL HC-TYPE-C-16P-01A or GCT USB4105-GF-A.
- **8-pin FPC:** XYECONN FPC09-Q1.0-8AH2.0 or Molex 200528-0080.
- **50-pin FPC:** JUSHUO AFC07-S50ECA-00 or Amphenol F32Q-1A7H1-11050.

**Not fitted:** C107, C110, C111, D103, FB103, FB104, R103, R109, R118, R125 (main board); J101 (display board).

**LEDs from LCSC:** XINGLIGHT XL-2020RGBC-WS2812B. Check its pin-1 mark before soldering.

## Display

2.8" ILI9341, 240 × 320, 50-pin 0.5 mm FPC, with 4-wire resistive touch. The touch is not used, but it gives the 4.0 mm thickness the case expects and protects the screen.

- **Known good:** Adafruit 1774 (MI0283QT-11), or BuyDisplay ER-TFT028-4 with the "Resistive Touch" option.
- **Outline:** 50.2 × 69.3 × 4.0 mm. Active area: 43.2 × 57.6 mm.
- **FPC:** leaves the middle of a short side, about 25.5 mm wide and 27 mm long. It must have plug-in contacts: 37-pin solder-tail panels don't fit.
- **Pinout:** 1 LEDK · 2–5 LEDA · 6–9 IM0–3 · 10 RESET · 33 SDO · 34 SDI · 35 RD · 36 WRX = D/C · 37 DCX = SCK · 38 CS · 40–42 VCC · 43 GND. Pins 44–47 (touch) only go to test points.
- **Without touch** (2.8 mm thick):
  - **Spacer:** add a 1.2 mm frame between the bezel and the panel, 50.2 × 69.3 mm outside with a 60 × 45.5 mm window (the size of the bezel opening).
  - **Screen protector:** 61–62 × 46–47 mm, for example a protector for the bottom screen of an original 3DS. Subtract its thickness from the frame.

## Speaker

| Space | |
|---|---|
| Outline | 15 × 11 mm |
| Height | 3.4 mm, from the PCB to the faceplate ledge |
| Pads (LS101) | 2.5 × 1.7 mm, centres 9.85 mm apart across the width, about 1 mm from the short end away from the D-pad |

- **Spring contacts (no soldering):** Same Sky CMS-151125-078S-67 (8 Ω) or CMS-151125-076S-67 (6 Ω), 15 × 11 × 2.5 mm. Contacts face the PCB.
- **Wired (soldered):**
  - **Size:** 15 × 11 mm, body at most 3.3 mm tall, 6–8 Ω, 0.5 W or more.
  - **Wiring:** cut the leads to about 1 cm and solder them to the LS101 pads. Polarity does not matter.
  - **Lead routing:** the pocket wall stops 1 mm above the PCB, so the leads pass under it.
- **Taller spring speakers** (for example the 1511 ones with a 3.0–3.3 mm body):
  - **Faceplate:** lower the pocket ledge to the body height plus about 0.4 mm.
  - **Contacts:** the springs must land on the pads.
- **H106 clearance:** the speaker body starts about 0.4 mm past the edge of the H106 mounting hole. Check that the screw head doesn't press on it.

## Other parts

- **Interconnect cable:** 8-pin FFC, 1.0 mm pitch, contacts on the same side.
  - **Length:** **50 mm**. The shortest path through the hinge is about 35–38 mm, and the cable must not be under tension.
  - **Parts:** GCT 10-08-A-0050-C-4-08-4-T or JUSHUO JS10A-08P-050-4-8.
- **Battery:** 1-cell LiPo, about 2000 mAh, 8 × 38 × 60 mm, with protection circuit and a JST PH 2-pin plug, for example PKCell LP803860. The pocket is about 66.8 × 38.8 × 8 mm.
  - **Polarity:** J102 pin 1 is BAT+ (it goes to F101). Check that the red wire lands on it before plugging in.
- **Shoulder buttons:** E-Switch TL3336AF160Q.
- **Wi-Fi antenna:** 2.4/5 GHz flex (FPC) antenna with an **MHF4 (IPEX-4)** plug and 0.81 mm cable, flat part at most about 27 × 12 mm. The one that comes with the board fits the connector; use it if it is small enough. U.FL (MHF1) antennas don't fit this connector.

## 3D printing

- **Faceplate:** `3d/faceplate/faceplate_v3_with_led_pockets.stl`. It is `v3.stl` with the LED pockets and collars merged, plus:
  - **Thicker skin:** most 0.8 mm panels are now 1.7 mm (`faceplate_thickening.stl`). That leaves 1.9 mm above the main board and 2.9 mm above the Orange Pi. The USB-C sits on the back, but its four shell legs come through: trim them flush on the front if they stick out more than 1.5 mm. Left as they were: the button rings, the LED pockets and light tunnels (with 0.5 mm around them), the Start/Select and side buttons, and the speaker.
  - **Over the Orange Pi:** its parts were placed from Orange Pi's DXF of the board; they are in the same places as on the Pi Zero. The panels over the HDMI and the Wi-Fi module stay 0.8 mm. The pocket over the two USB-C leaves 3.4 mm (the connectors are about 3.2 mm).
  - **ABXY LED pockets:** the collars left small gaps beside the cutter (and the one at the bottom right was open on one side); `faceplate_pocket_fill.stl` fills them, so each pocket is exactly the cutter's shape, like the D-pad ones.
  - **Button key tabs:** the light tunnels end where the B (left and right) and Y (bottom) tabs are and had taken their lower 0.8 mm; the tabs are whole again. Light still passes beside and under them.
  - **microSD closure:** 1.7 mm instead of 0.8 mm, leaving 2.9 mm above the Orange Pi for the card and its slot.
  - **To rebuild it:** open `faceplate_led_cuts.scad` with the five STLs in the same folder.
  - **In Blender:** Union with the collars, the pocket fill and the thickening first, then Difference with the cutter, then Union with the key tabs (in the `.scad`), all with the Exact solver.
- **Lower case:** `3d/case/p101_lower_case_fixed.STL`.
- **Display housing, bezel, buttons:** the upstream STL files.

## Orange Pi Zero 2W

`software/orange_pi/` sets everything up on Armbian (Debian, "current" kernel). The sound and backlight drivers are Armbian kernel patches, so mainline kernels won't work. Do the Armbian first-boot setup over SSH, then:

```
cd software/orange_pi
sudo ./install.sh            # ROM_SIZE=16G sudo ./install.sh for a bigger ROM drive
sudo reboot
sudo ./check.sh --test       # status, then backlight, LEDs, sound and buttons
```

What it sets up:
- **Overlay `pitin-opi-zero2w.dts`:**
  - display: `mi0283qt` driver on SPI1 CS0 at 50 MHz, `rotation = <90>` (use 270 if the picture is upside down);
  - backlight: PWM4 at 20 kHz, as `/sys/class/backlight/pitin-backlight`;
  - LEDs: spidev on CS1, with PH8 as the chip select;
  - sound: I2S0 to the MAX98357A, through the Armbian kernel's AHUB driver;
  - the 15 buttons as one gamepad;
  - power button: systemd powers off;
  - power-off line on pin 5;
  - USB cable detect;
  - UART0 off.
- **RetroArch** starts on the screen at boot. There is no EmulationStation.
  - **Save states:** the game state is saved and restored automatically, including at power-off.
  - **Cores:** they come from the Debian packages. If the packaged RetroArch lacks KMS, `install.sh` builds it from source.
- **ROM drive:** a FAT32 image (`~/roms.img`) mounted on `~/roms`, with a folder per console. Plugged into a computer, it shows up there as a USB drive (`pitin-usbd`); a charger changes nothing.
- **Sound:** both channels are mixed for the single amplifier. Set the volume with `amixer sset Master 60%`.
- **`pitin-daemon`:** screen brightness, volume, the LEDs and a settings page at `http://<ip>:8080` (`pitin-web.html`). Settings are kept across reboots.
  - **LED effects:** each LED has its own colour. Off, static (steady), wave (a rainbow, or the LEDs' own colours, travels from LED to LED in a chosen order), fade (all LEDs change colour together) and reactive (a pressed button lights the LEDs beside it: two for the D-pad and ABXY, its own side for the shoulders).
  - **Settings page:** LEDs, uploading ROMs over Wi-Fi (sorted into the console folders by file type) and deleting them, screen brightness, volume, status, restart and power off. Works on a phone or a computer, in French or English depending on the browser's language.
  - **Password:** the page is open to the local network. Set `WEB_PASSWORD=` in `/etc/default/pitin` and run `sudo systemctl restart pitin-daemon` to require one.
  - **On-screen messages:** the daemon's hotkeys (screen brightness, volume, LEDs) show their value as RetroArch on-screen text; RetroArch's own hotkeys show RetroArch's messages. Volume is the same "Master" volume as on the settings page.
  - **LED auto brightness:** on by default (switch on the settings page). The LEDs dim with the screen, so the screen brightness hotkey sets both; the LED brightness setting is then their maximum, at full screen brightness, and the page shows the brightness they have now.
  - **Load, restart and quit:** SPECIAL + L1, + B and + START act only when held for a second, so a slip doesn't lose progress. Quitting saves the game state (`savestate_auto_save`), and it is loaded again when the game starts.
  - **List of hotkeys:** SPECIAL + SELECT pauses the game and shows every SPECIAL hotkey on a card (a RetroArch overlay, `overlay/`). While it is open, the buttons do the same without SPECIAL (volume, brightness, LEDs, save, slot…); SELECT closes it.
  - **Changing the card:** edit the texts or colours in `overlay/make_card.py` and run it, or edit the PNGs (320 × 240, transparent around the card) in any image editor; then run `install.sh` again.
  - **How:** the messages, quit / reset and the card use RetroArch's network commands (UDP 55355, also reachable from the local network). Language: `LANGUAGE=` in `/etc/default/pitin` (`en` or `fr`; empty = the system's language), then run `install.sh` again for the card.

Hotkeys (hold SPECIAL):

| SPECIAL + | Action |
|---|---|
| X | RetroArch menu |
| L1 (hold 1 s) / R1 | Load / save state |
| LEFT / RIGHT | Previous / next save slot |
| UP / DOWN | Volume up / down |
| B (hold 1 s) | Reset |
| START (hold 1 s) | Quit the game (it is saved) |
| L2 / R2 | Screen brightness down / up |
| Y | LEDs on / off (they come back with the same effect) |
| A | Next LED effect |
| SELECT | List of hotkeys on the screen |

Pins that change role:

| Pin | Pi Tin use | On the Orange Pi |
|---|---|---|
| 5 | `SHUTDOWN_PS`: power-off output | PI7: gpio-poweroff, active low |
| 8 / 10 | `USB_PWR` (USB detect) / RIGHT | PH0 / PH1: the UART0 debug console, disabled by the overlay. U-Boot still uses it, so don't hold RIGHT while booting. |
| 12 / 35 / 40 | I2S BCLK / LRCLK / DATA | PI1 / PI2 / PI3 (I2S0) |
| 16 | Backlight PWM (`RS/BL` on the display board) | PI14: PWM4 |
| 18 | UP | PH4: plain input |
| 21 | `LED_CS`: gates the LED buffer | PH8 as a GPIO chip select (`cs-gpios`) |
| 26 | `SHUTDOWN_PI`: power button | PH9, which is also SPI1 CS1: used as a plain input |

**Not tested on hardware.** Sound is the least certain part: it relies on the AHUB driver and on overlay settings reported working on this board on the DietPi forum. `check.sh` shows which part failed. `install.sh` stops if the overlay doesn't apply to the board's device tree.

Hardware notes:
- **USB-drive mode:** TP132/TP133 must go to the D+/D− of the OTG USB-C port (USB0). The D+/D− pads under the board look like they belong to the host-only port; check with a multimeter.
- **Top side:** the main PCB covers a strip of about 6 mm along the header, so nothing there may stick up.
- **Bottom side:** it faces the battery and has an SPI flash chip about 1.5 mm tall. Use thicker foam or Kapton there.
- **Wi-Fi antenna:** the Orange Pi Zero 2W has no antenna on the board, only an IPEX-4 (MHF4) connector next to the 24-pin FPC (ANT1 in the schematic), and without one there is no Wi-Fi. The faceplate has a pocket over that connector and a channel into the thin panel over the Wi-Fi module, for the plug and its cable. Stick a small flex antenna to the inside of that panel (room: about 27 × 12 mm) and coil the spare cable there. The boards are close, so the range is shorter than with the antenna outside the case: check it before closing the case.
