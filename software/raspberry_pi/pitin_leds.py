#!/usr/bin/env python3
"""Pi Tin RGB LEDs (10x WS2812B-2020) via SPI0 CE1 (GPIO9) -> 74AHCT1G125 gate.

Needs in config.txt:  dtoverlay=spi0-2cs,cs1_pin=9,no_miso   and   core_freq_min=400
The buffer only passes MOSI while CE1 (GPIO9) is low, so the display on CE0 never
reaches the LEDs.  Each WS2812 bit is sent as one SPI byte:
    '0' -> 0b11000000 (~0.32 us high)    '1' -> 0b11111000 (~0.80 us high)
At 400 MHz core clock the SPI runs at 6.25 MHz (160 ns per SPI bit, 1.28 us per LED bit).
The reset/latch (>280 us low) happens by itself: when CE1 goes high the buffer
turns off and R132 holds the LED data line low.

Usage:  python3 pitin_leds.py demo | off | set R G B
"""
import sys, time, spidev

N_LEDS = 10
# Which physical LED sits at each position of the data chain (index 0 receives the data first).
CHAIN_MAIN    = ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10']   # main board
CHAIN_VARIANT = ['D7', 'D8', 'D9', 'D10', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6']   # "everything on the back" variant
CHAIN = CHAIN_VARIANT
# D1/D2: Start/Select   D3-D6: D-pad corners   D7-D10: corners of the ABXY diamond
BRIGHTNESS = 0.25          # keep it low: 10 LEDs at full white draw ~0.5 A

_LUT = [bytes(0xF8 if (v >> (7 - i)) & 1 else 0xC0 for i in range(8)) for v in range(256)]

class Leds:
    def __init__(self, bus=0, dev=1, hz=6_400_000):
        self.spi = spidev.SpiDev()
        self.spi.open(bus, dev)          # /dev/spidev0.1 = CE1 = GPIO9
        self.spi.mode = 0
        self.spi.max_speed_hz = hz
    def show(self, colors):
        buf = bytearray(b'\x00' * 2)     # short idle-low lead-in
        for r, g, b in colors:
            for c in (g, r, b):          # WS2812 order is GRB
                buf += _LUT[max(0, min(255, int(c * BRIGHTNESS)))]
        buf += b'\x00' * 2
        self.spi.writebytes2(buf)
        time.sleep(0.0003)               # latch
    def show_by_ref(self, colors_by_ref, off=(0, 0, 0)):
        """colors_by_ref: {'D7': (r, g, b), ...} using the PCB reference of each LED."""
        self.show([colors_by_ref.get(ref, off) for ref in CHAIN])
    def off(self):
        self.show([(0, 0, 0)] * N_LEDS)

def wheel(p):
    p %= 255
    if p < 85:  return (255 - p * 3, p * 3, 0)
    if p < 170: p -= 85; return (0, 255 - p * 3, p * 3)
    p -= 170;   return (p * 3, 0, 255 - p * 3)

if __name__ == '__main__':
    leds = Leds()
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'demo'
    if cmd == 'off':
        leds.off()
    elif cmd == 'set':
        r, g, b = (int(x) for x in sys.argv[2:5])
        leds.show([(r, g, b)] * N_LEDS)
    else:
        try:
            t = 0
            while True:
                leds.show([wheel(t + i * 25) for i in range(N_LEDS)])
                t += 3; time.sleep(0.03)
        except KeyboardInterrupt:
            leds.off()
