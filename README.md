# Pi Tin mod

Personal build of jackw01's [Pi Tin](https://github.com/jackw01/pi-tin) (3D-printed clamshell version, KiCad 10). It adds 10 RGB LEDs under the buttons, a centred speaker, a USB-drive mode for the SD card, and ESD protection on USB. The upstream [build guides](https://jackw01.github.io/pi-tin/) still apply. License: CERN-OHL-W v2.

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
| RGB LEDs | D1–D10 (WS2812B-2020) | Chain: D7 → D8 → D9 → D10 → D1 → … → D6 |
| LED driver | U106 74AHCT1G125, R130 330 Ω | Input: SPI MOSI. Enabled only by SPI CE1 (GPIO9), so the display (CE0) never reaches the LEDs. |
| | R131 10 k, R132 100 k | R131: buffer off at boot. R132: data line low. |
| USB detect | R133/R134 100 k | VBUS divider to GPIO14 |
| USB-drive mode | U107 USBLC6-2SC6, TP132 (D+), TP133 (D−) | Wire TP132/TP133 by hand to the Pi's USB D+/D− test pads. Optional. |

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

## 3D printing

- **Faceplate:** `3d/faceplate/faceplate_v3_with_led_pockets.stl`. It is `v3.stl` with the LED pockets and collars merged.
  - **To rebuild it:** open `faceplate_led_cuts.scad` with the three STLs in the same folder.
  - **In Blender:** Union with the collars first, then Difference with the cutter, both with the Exact solver.
- **Lower case:** `3d/case/p101_lower_case_fixed.STL`.
- **Display housing, bezel, buttons:** the upstream STL files.

## Raspberry Pi Zero 2 W

`config.txt`, on top of the standard Pi Tin setup:

```
dtoverlay=spi0-2cs,cs1_pin=9,no_miso   # replaces spi0-1cs; CE1 (GPIO9) gates the LED buffer
core_freq_min=400                      # fixed SPI clock for the LED timing
dtoverlay=dwc2,dr_mode=peripheral      # USB-drive mode
gpio=14=ip,pn                          # USB cable detect
```

- **`pitin_leds.py`:** install it in `/usr/local/bin/`. It needs `python3-spidev` and uses `/dev/spidev0.1`. Usage: `demo`, `off` or `set R G B`.
- **`pitin_usb_mode.sh`:** install it in `~/RetroPie/retropiemenu/`. The ROMs must be on their own FAT32 or exFAT partition (default `/dev/mmcblk0p3`, set by `ROMPART`/`MNT` in the script).
- **`spidev1-on.dts`:** only needed if `/dev/spidev0.1` is missing.

## Orange Pi Zero 2W (software not written yet)

The boards need no changes: power, SPI (pins 19/21/23/24) and I2S (pins 12/35/40) are on the same header pins.

| Pin | Pi Tin use | On the Orange Pi |
|---|---|---|
| 5 | `SHUTDOWN_PS`: power-off output to the power circuit | PI7: gpio-poweroff, active low |
| 8 / 10 | `USB_PWR` (USB detect) / RIGHT button | UART0 debug console: disable it. Don't hold RIGHT at boot. |
| 18 | `RST`: display reset, also the backlight switch on the display board (`RS/BL`) | Plain GPIO. Dimming would need the `pwm-gpio` driver. |
| 21 | `LED_CS`: GPIO9, used as SPI CE1 to gate the LEDs | PH8: CS for the LED spidev (`cs-gpios`) |
| 26 | `SHUTDOWN_PI`: power button | PH9, which is also SPI1 CS1: keep it as a plain GPIO |

- **Overlay contents:**
  - ILI9341 on SPI1 CS0;
  - an spidev for the LEDs on CS1 (PH8);
  - I2S0 with the MAX98357A;
  - the 15 buttons as gpio-keys;
  - the power button (PH9);
  - gpio-poweroff (PI7);
  - UART0 off.
- **I2S audio:** needs the Orange Pi vendor kernel (6.1) or a kernel with the AHUB patches.
- **USB-drive mode:** only the corner USB-C port (USB0) can be a USB device. Check with a multimeter which port the board's D+/D− pads belong to before wiring TP132/TP133.
- **Clearance:**
  - **Top:** the main PCB covers a strip of about 6 mm along the header, so nothing there may stick up.
  - **Bottom:** it faces the battery and has an SPI flash chip about 1.5 mm tall. Use thicker foam or Kapton there.
