# Pi Tin mod — project package

A modified [Pi Tin](https://github.com/jackw01/pi-tin) handheld (KiCad 10), with these changes:
- 10 addressable RGB LEDs under the buttons;
- a centered speaker;
- SD card access as a USB drive through the main USB-C port;
- ESD protection on the USB data lines;
- connector footprints that accept both the LCSC parts and the Mouser/DigiKey parts.

The main board is the **"everything on the back" variant**: all new parts are on the back side; only the LEDs, the buttons and the original charge LEDs are on the front.

Original design by jackw01 (alley cat engineering). Hardware license: CERN-OHL-W v2.

## What is in this zip

| Path | What it is |
|---|---|
| `fab/main_board_gerbers.zip` | **Ready to upload** to the board maker: main board Gerbers, drill files, drill maps and the Gerber job file (see "Ordering the boards"). |
| `fab/display_board_gerbers.zip` | Same for the display board. |
| `kicad/pcb_main_r2/` | Main board, KiCad 10 project (`mintypcb.*`), with the DRC fixes applied and the zones refilled. |
| `kicad/pcb_main_r2/mintypcb.kicad_dru` | Two DRC rule exceptions, both explained in "DRC". KiCad loads this file automatically. |
| `kicad/pcb_main_r2/pitin_extra.kicad_sym` | Symbols added for the mod (USBLC6-2SC6, 74AHCT1G125). |
| `kicad/pcb_main_r2/pitin_extra.pretty/` | Two footprints that accept both suppliers (see "Connectors"). |
| `kicad/pcb_display_r2a/` | Display interconnect board, KiCad project. Unchanged from upstream except the 8-pin FPC footprint (J102). `displaypcb.kicad_dru` holds one DRC rule exception (see "DRC"). |
| `bom/1_set/`, `bom/5_sets/` | Bills of materials for main board + display board together, for 1 or 5 sets. One CSV per shop (`BOM_LCSC.csv`, `BOM_Mouser_FR.csv`, `BOM_DigiKey_FR.csv`), ready for the shop's BOM upload tool, plus `BOM_comparison.csv` with the three shops side by side. `BOM_Mouser_FR_speaker_display_only.csv` is a small Mouser cart with just the speaker and the display, to go with an LCSC order. |
| `3d/faceplate/faceplate_v3_with_led_pockets.stl` | **Ready to print**: v3 with the LED pockets, light tunnels and collars already merged. No Blender work needed. |
| `3d/faceplate/v3.stl` | Your faceplate (v3), unmodified. |
| `3d/faceplate/faceplate_led_cutter.stl` | Template to **subtract** from v3: the LED pockets and the light tunnels (one closed solid per LED, 344 triangles). |
| `3d/faceplate/faceplate_led_collars.stl` | Template to **add** to v3: reinforcement collars around the pockets (18 closed solids, 1,308 triangles). |
| `3d/faceplate/faceplate_led_cuts.scad` | Rebuilds the merged faceplate from the three STLs in OpenSCAD, if you ever change v3. |
| `3d/faceplate/faceplate_preview.png` | Back of the faceplate around the LEDs, before and after. Colour shows height. |
| `3d/case/p101_lower_case_fixed.STL` | Your modified lower case (same 93 × 66 × 24.85 mm outer size as the original p101). |
| `software/raspberry_pi/` | Raspberry Pi versions of the LED script, the USB-drive mode script and an SPI overlay (see "Software"). |
| `images/variant_comparison.png` | Main version vs. this variant, front and back copper, before the DRC fixes. |

## Status

**Done**
- Schematic and PCB changes (below).
- BOMs: researched 8–9 Oct 2026, quantities rounded to the cheapest buy. Speaker, display and battery sources included (see "Speaker, display and battery").
- Faceplate: ready-to-print merged STL, plus clean templates (see "Faceplate").
- Connector footprints that accept the Mouser/DigiKey parts.
- DRC errors of the variant fixed (see "DRC").
- Gerbers and drill files for both boards (see "Ordering the boards").

**Still to do**
- **Write the Orange Pi Zero 2W software** (see below). Not needed for the Raspberry Pi.

**Physical checks**
- **Speaker vs. the H106 screw.** The speaker body starts about 0.4 mm past the edge of the H106 mounting hole (this was already so in your main version). Before closing the case, check that the screw head and the faceplate boss under H106 don't press on the speaker.
- On the Orange Pi, check which USB port the D+/D− pads belong to (see below).
- Check the pin-1 mark of the LCSC LEDs before soldering.
- Check the battery polarity before plugging it in (see "Battery").

## Board changes (main PCB)

| Block | Parts | How it works |
|---|---|---|
| RGB LEDs | D1–D10 (WS2812B-2020 or compatible), C113–C122 (100 nF, back side, next to each LED) | Chain order on this variant: D7 → D8 → D9 → D10 → D1 → … → D6. The net `LED_LOOP` joins D10 to D1. |
| LED driver | U106 (74AHCT1G125) | Input: SPI MOSI (taken next to the display connector). Output: 5 V data to D7 through R130 (330 Ω). |
| LED driver control | R131 (10 k), R132 (100 k) | The buffer's output-enable is GPIO9, used as SPI CE1, so only SPI transfers to CE1 reach the LEDs; the display on CE0 never does. R131 pulls OE up so the buffer is off at boot. R132 holds the LED data line low. |
| ESD | U107 (USBLC6-2SC6) | Sits on the USB-C D+/D− lines, between J101 and the test points TP132/TP133. TP132/TP133 are wired by hand to the Pi's USB data pads. Harmless if the wires are not fitted. |
| USB cable detect | R133/R134 (100 k / 100 k) | VBUS divider to GPIO14 (`USB_PWR`): high when a cable is plugged in. |
| Other fixes | — | Corrected R130's part number to match its 330 Ω value (it pointed to a 5.1 k part). |

## Connectors (both suppliers fit)

| Ref. | LCSC part | Mouser/DigiKey part | Footprint change |
|---|---|---|---|
| J101 USB-C | HCTL HC-TYPE-C-16P-01A | GCT USB4105-GF-A | Rear shell slots 0.6 × 1.2 → 0.6 × 1.4 mm. The pad stays 1.7 mm long to keep 0.2 mm to the +BATT track. |
| J103 (main), J102 (display), 8-pin FPC | XYECONN FPC09-Q1.0-8AH2.0 | Molex 200528-0080 | Same body; side-tab pads widened outwards (2.6 × 1.7 mm at ±6.0). |
| J103 (display), 50-pin FPC | JUSHUO AFC07-S50ECA-00 | Amphenol F32Q-1A7H1-11050 | None needed. |

KiCad's DRC was run before and after the change, with zones refilled: no new violations.

## DRC

### What was fixed on the main board

| Problem | Fix |
|---|---|
| The USB_PWR track (front) passed 0.55 mm from the H106 mounting hole. | It now goes around the hole, at least 1.2 mm from its edge. |
| R131 and the LED_CS via sat inside the H106 keep-out. | R131 moved to the free area left of the hole, with a new via and a new front track. Its 3.3 V feed was rerouted. |
| The LED_CS track ran across the FB103/FB104 copper bridges, which shorted it to both speaker outputs. | Rerouted above the C110 / FB103 / FB104 / C111 row. |
| R130 and R132 sat under the SW111 shoulder button. | Moved into the free space next to it and turned 90°, with LED_BUF and LED_DIN rerouted. The 5 V copper area on the back stays in one piece. |
| R133 sat under the USB-C connector body. | Moved next to the connector, with VBUS and USB_PWR rerouted. |
| The USB-C GND pins A1/B12 were not joined to the GND plane. | Two short back-side tracks. |
| D8 and SW116 had too few thermal-relief spokes to GND. | Their GND pads now connect solidly to the plane. R132's GND pad too: its spokes left a 0.11 mm neck of copper. |
| TP132 and TP133 overlapped other parts. | Moved to free spots. TP133 still touches C120's courtyard (see below). |

Display board: the WEEE logo was flagged as a part missing from the schematic. It is now marked "board only".

### Final result

KiCad 10.0.6, zones refilled, schematic parity check on.

| | errors | unconnected | schematic parity errors |
|---|---|---|---|
| Main board | 1 | 13 | 0 |
| Display board | 0 | 0 | 0 |

The remaining items, all accepted:
- **13 unconnected pairs on the main board:** each is the two pads on one side of a tactile switch, which the switch joins internally. The upstream design has the same 13.
- **H106 / LS101 courtyard overlap:** already present in your main version. The speaker body starts about 0.4 mm past the edge of the mounting hole; see "Physical checks".
- **Two rule exceptions in `mintypcb.kicad_dru`:**
  - the J101 shell tabs need only one thermal spoke, because tracks also tie them to GND;
  - TP133, a bare wire pad, may touch C120's courtyard.
- **One rule exception in `displaypcb.kicad_dru`:** the JP102 solder jumper may touch J102's courtyard. This was already so upstream.
- **Warnings** (silkscreen overlaps, missing library warnings, one 0.10 mm GND neck near the USB-C connector, field differences between schematic and PCB): all were already there in your variant before these fixes, and none affects the boards.
  - The field differences are things like a trailing space in a part number. Tools → Update PCB from Schematic (F8) clears them if you like.

## Ordering the boards

Upload `fab/main_board_gerbers.zip` and `fab/display_board_gerbers.zip` to the board maker as they are, one order line each. Each zip holds the 9 Gerber layers, the plated and non-plated drill files, drill maps and a Gerber job file. They were plotted from copies of the boards with refilled zones. The TrueType silkscreen text was turned into shapes first, so the logo font comes out as designed.

| | Main board | Display board |
|---|---|---|
| Size | 89.15 × 55.65 mm | 39.15 × 46.15 mm |
| Layers | 2 | 2 |
| **Thickness** | **1.0 mm** | **0.6 mm** |
| Copper | 1 oz (35 µm) | 1 oz (35 µm) |
| Smallest track / gap | 0.2 / 0.2 mm | 0.2 / 0.2 mm |
| Smallest hole / via | 0.3 mm hole, 0.6 mm via | 0.3 mm hole, 0.6 mm via |

- **Thickness:** set it by hand on the order form, because the makers default to 1.6 mm. These values come from the KiCad files (the board stackup).
- **Everything else** is within standard 2-layer limits at JLCPCB, PCBWay and similar makers, so no extra-cost options are needed.
- **Surface finish:** ENIG makes the fine-pitch USB-C and FPC connectors easier to solder by hand. HASL works too.

## BOM summary

All prices exclude shipping and taxes. Exchange rate: 1 € = 1.1177 US$.

| File | What it covers | 1 set | 5 sets |
|---|---|---|---|
| `BOM_LCSC.csv` | both boards + FFC cable (no speaker, no display) | ≈ 28.18 € (US$ 31.50) | ≈ 63.78 € (US$ 71.29) |
| `BOM_Mouser_FR.csv` | both boards + FFC + speaker + display | 48.02 € | 220.73 € |
| `BOM_DigiKey_FR.csv` | both boards + FFC + speaker (display out of stock there) | ≈ 34.50 € | ≈ 151.07 € |
| `BOM_Mouser_FR_speaker_display_only.csv` | only speaker + display | 17.61 € | 88.05 € |

- **Cheapest way to order:** LCSC for the boards, plus the small Mouser cart for the speaker and the display. For 5 sets that is ≈ 63.78 € + 88.05 €, and the Mouser part ships free (above 75 €). The battery comes from a third shop (see below).
- **LEDs on LCSC:** the Worldsemi WS2812B-2020 is no longer sold there, so the LCSC BOM uses the XINGLIGHT XL-2020RGBC-WS2812B: same pinout and protocol, 5 mA per colour.
- **Substitutions:** every part that differs from the schematic is listed with a reason in the `note` columns of `BOM_comparison.csv`.
- **Not fitted:** C107, C110, C111, D103, FB103, FB104, R103, R109, R118 and R125, plus J101 on the display board. They are not in the BOMs.
- **Shoulder buttons:** TL3336AF160Q, for the 3D printed case.

## Speaker, display and battery

Prices and stock checked 9 Oct 2026.

### Speaker (no soldering)

**Same Sky CMS-151125-078S-67.** It is the 8 Ω version of the original CMS-151125-076S-67 (6 Ω): same 15 × 11 × 2.5 mm body, same spring contacts, IP67. jackw01's own case model uses this exact part.
- Mouser 490-CMS-151125078S67: 2.17 € each, 890 in stock.
- DigiKey 102-4998-ND: US$ 3.04 each, 719 in stock.
- **8 Ω instead of 6 Ω:** slightly lower maximum volume from the MAX98357A, nothing else changes. The 6 Ω original is still sold (Mouser 490-CMS-151125076S67, 2.61 €) if you prefer it.
- **Contacts:** two leaf springs, one along each long side, with their bumps at one short end, 9.82 mm apart across the width. They press on the two LS101 pads.
- **Fitting:** as in the original guide, put it in the faceplate pocket with the contacts facing up (towards the PCB) and at the end away from the D-pad, which is where the LS101 pads are.
- **Not on LCSC:** LCSC has no spring-contact 15 × 11 mm speaker that fits and is in stock. The Dragonstate part listed before (HDK-151108ZA-5W13) appears to have wire leads, so it was removed.

### Display

**Adafruit 1774** (Multi-Inno MI0283QT-11). It is the panel the original Pi Tin case was designed around. Its 50-pin pinout matches the display board, checked pin by pin against the datasheet.
- Mouser 485-1774: 15.44 €, 19 in stock (enough for 5 sets).
- DigiKey 1528-2662-ND: out of stock.
- **Outline:** 50.2 × 69.3 × 4.0 mm; active area 43.2 × 57.6 mm.
- **Fitting:** the FPC goes into J103 with its contacts facing up (original build guide).

**Cheaper alternative, not tested:** BuyDisplay (EastRising) ER-TFT028-4, ordered with the 4-wire resistive touch panel.
- Its datasheet shows the same 50-pin pinout and the same outline.
- About US$ 7 each for 10 pieces, shipped from China. The single-unit price and shipping were not checked.
- Not verified: which side the FPC contacts are on, and the exact position of the active area.
- Order it **with** touch: without touch it is 2.8 mm thick instead of 4.0 mm, and needs a shim.

When comparing any other panel, compare the SPI function of each pin: pin 36 must be D/C and pin 37 SCK. Datasheets label these pins differently (WRX, D/CX, SCL).

### Battery

**1-cell LiPo, 2000 mAh, about 8 × 38 × 60 mm, with protection circuit and a JST PH 2-pin plug.** The original guide lists 8 × 38 × 60 or 8 × 35 × 61 mm cells, such as Adafruit 2011 (a PKCell LP803860). The pocket in the lower case is about 66.8 × 38.8 mm, with 8 mm of thickness. Your modified lower case has the same pocket.

- **Mouser can't ship lithium batteries to France,** and Adafruit 2011 is out of stock. Options:
  - **Welectron (Germany), PKCell LP803860 2000 mAh with PH plug, art. PL1-803860:** 6.90 € including German VAT, 100+ in stock, UPS to the EU 9.90 €. The page doesn't state dimensions, protection or polarity. It is the same cell as Adafruit 2011, which has a protection circuit, but ask the shop to confirm.
  - **Eckstein (Germany), art. ZB07001, PKCell LP803860:** 7.95 €, protection stated. It measures about 62 × 38.5 × 8.5 mm, which is tight in the pocket. Check that they ship to France.
- **Polarity:** on this board J102 pin 1 is BAT+ (it goes to fuse F101) and pin 2 is GND.
  - Adafruit/PKCell batteries are wired this way: the red wire lands on pin 1, as in the original build photos.
  - Many other batteries are wired the other way.
  - **Check before plugging in.** Find the J102 pin that has continuity to F101; the battery's red (+) wire must land on that pin. If it's reversed, swap the two contacts in the plug: lift each latch with a needle and move one wire at a time, so the wires never touch.

## Faceplate

**Just print `faceplate_v3_with_led_pockets.stl`.** It is v3 with the pockets, tunnels and collars already merged.

How it was checked:
- **Geometry:** the merged mesh was compared with "v3 + collars − cutter" at 12.8 million points on a 0.05 mm grid around the LEDs, and again at 23 million points on a different grid. No differences.
- **Mesh quality:** the merge added no open or non-manifold edges and no zero-area faces.
- **Leftover defects from v3 itself:** v3 already has a few small open or overlapping edges, away from the LEDs. They sit at the right edge (X 83–90 mm, Z 9–25 mm in the STL) and at one spot between the D-pad and Select (X 30–36, Z 39–45). They are copied unchanged. Slicers ignore them; Blender's 3D-Print Toolbox "Make Manifold" can clean them if you need to.

**Merging the templates yourself** (Blender or OpenSCAD), for example after editing v3:
- **Import:** all three STLs share the same coordinates, so import them with the same settings and don't move them.
- **Step 1:** on v3, add a Boolean modifier: **Union**, Object = collars, Solver = **Exact**. Apply it.
- **Step 2:** add another Boolean modifier: **Difference**, Object = cutter, Solver = **Exact**. Apply it.
- **Order matters:** collars first, then the cutter. The collars reach 0.15 mm into the pockets so that no thin sliver is left; the cutter removes that overlap.
- **If Blender shows stray faces:** tick "Self Intersection" and "Hole Tolerant" in the modifier. These are needed because of v3's own defects listed above.
- **OpenSCAD:** `faceplate_led_cuts.scad` does both steps.

What changed in the templates:
- **Old cutter:** 28 overlapping boxes.
- **Old collars:** 816 loose fragments from a pixel grid (15,972 triangles), with edges shared by 4 faces. This is what confused Blender and made it slow.
- **Now:** every template piece is one closed solid with outward normals.
  - The staircase outlines of the collars were smoothed to within 0.06 mm.
  - Hairline gaps between collar and pocket were closed.
  - The positions and heights are the same as before: pockets and tunnels Y 0.6–2.6, collars Y 1.0–3.9.

## Software

### Raspberry Pi Zero 2 W (`software/raspberry_pi/`)

Use the standard Pi Tin setup, with these changes in `config.txt`:

```
dtoverlay=spi0-2cs,cs1_pin=9,no_miso   # replaces spi0-1cs; CE1 on GPIO9 gates the LED buffer
core_freq_min=400                      # fixed SPI clock for the LED timing
dtoverlay=dwc2,dr_mode=peripheral      # USB drive mode
gpio=14=ip,pn                          # USB_PWR cable-detect input
```

The scripts:
- **`pitin_leds.py`:** drives the LEDs through `/dev/spidev0.1`. Set `CHAIN = CHAIN_VARIANT` for this board. Usage: `pitin_leds.py demo|off|set R G B`.
- **`pitin_usb_mode.sh`:** exposes the ROM partition to a computer as a USB drive while the cable is plugged in.
- **`spidev1-on.dts`:** only needed if `/dev/spidev0.1` does not appear.

### Orange Pi Zero 2W (planned)

**The board does not need changes for the Orange Pi.** Power, SPI (pins 19/21/23/24) and I2S (pins 12/35/40) are on the same header pins, and everything else is a plain GPIO. The work is all software: there is no RetroPie, and every Pi-specific piece has to be replaced.

What to write:
- one device-tree overlay that sets up:
  - the ILI9341 display on SPI1 CS0;
  - an spidev on CS1 with `cs-gpios` on PH8 (pin 21) for the LEDs;
  - I2S0 with the MAX98357A;
  - the 15 buttons as gpio-keys;
  - the power button on PH9 (pin 26);
  - gpio-poweroff on PI7 (pin 5, active low);
  - UART0 turned off.
- I2S audio needs the Orange Pi (vendor 6.1) kernel or a kernel with the AHUB patches.

Pins that change role:

| Pin | Pi Tin use | On the Orange Pi |
|---|---|---|
| 8 / 10 | USB detect / RIGHT button | They are the serial debug console (UART0): disable it. Don't hold RIGHT during boot. |
| 18 | Backlight PWM | No hardware PWM there: use the kernel `pwm-gpio` driver or a fixed brightness. |
| 26 | Power button | It is SPI1 CS1: keep it as a plain GPIO. |

Hardware checks:
- **USB drive mode:** only the corner USB-C port (USB0, also the power input) can act as a USB device. The D+/D− pads under the board look like they belong to the middle port, which is host-only. Check with a multimeter before wiring TP132/TP133.
- **Top side:** the main PCB covers a ~6 mm strip along the header on the board's top side, so nothing there may stick up.
- **Bottom side:** the bottom faces the battery and carries a ~1.5 mm SPI flash chip. Use thicker foam or Kapton there.
