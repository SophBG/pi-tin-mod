#!/usr/bin/env python3
"""Draws the hotkey list for SPECIAL + SELECT next to this file: help-card-en.png and help-card-fr.png.

The card is only a picture: RetroArch shows it over the game while it is open. To change it, edit CARDS or
the colours below and run:  python3 make_card.py   (needs Pillow and the DejaVu fonts; on Debian or Ubuntu:
sudo apt install python3-pil fonts-dejavu-core). Then run install.sh again and restart RetroArch. You can also
edit the PNGs directly in any image editor: 320 x 240, transparent where the game should show.

What the buttons do is in pitin-daemon (Buttons) and retroarch-pitin.cfg: change it there too if you move a
hotkey.
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
FONTS = '/usr/share/fonts/truetype/dejavu/'
W, H = 320, 240                    # the screen

# Each card: title (with buttons in front of it), the buttons that close it, two columns of (buttons, what they
# do), an optional note under them, the label size and where the second column starts. A pair is less / more, or
# previous / next.
CARDS = {
    'help': {
        'en': {'title': (['SPECIAL'], '+  SHORTCUTS'), 'close': (['SELECT'], 'close'),
               'cols': [('GAME', [(['X'], 'RetroArch menu'), (['L1', 'R1'], 'Load* / save'), (['◀', '▶'], 'Save slot'),
                                  (['B'], 'Restart*'), (['START'], 'Quit*')]),
                        ('CONSOLE', [(['▲', '▼'], 'Volume'), (['L2', 'R2'], 'Screen brightness'), (['Y'], 'LEDs on / off'),
                                     (['A'], 'Next LED effect'), (['SELECT'], 'This list')])],
               'note': 'Here: press without SPECIAL.     * hold for a second'},
        'fr': {'title': (['SPECIAL'], '+  RACCOURCIS'), 'close': (['SELECT'], 'fermer'),
               'cols': [('JEU', [(['X'], 'Menu RetroArch'), (['L1', 'R1'], 'Charger* / sauver'), (['◀', '▶'], 'Emplacement'),
                                 (['B'], 'Recommencer*'), (['START'], 'Quitter*')]),
                        ('CONSOLE', [(['▲', '▼'], 'Volume'), (['L2', 'R2'], 'Luminosité écran'), (['Y'], 'LEDs marche / arrêt'),
                                     (['A'], 'Effet LED suivant'), (['SELECT'], 'Cette liste')])],
               'note': 'Ici : appuyez sans SPECIAL.     * maintenir une seconde'},
        'size': 10, 'col2': 140},
}

# Colours (red, green, blue, opacity 0-255): the settings page's dark theme.
INK = (238, 241, 244, 255)         # text
MUTED = (152, 161, 171, 255)       # column titles, "close", the note
CARD = (24, 27, 31, 236)           # card background (a little see-through)
KEY = (42, 47, 53, 255)            # button shapes
LINE = (52, 58, 66, 255)           # card border
ROUND = {'A', 'B', 'X', 'Y'}       # drawn as round buttons

bold = lambda size: ImageFont.truetype(FONTS + 'DejaVuSans-Bold.ttf', size)
reg = lambda size: ImageFont.truetype(FONTS + 'DejaVuSans.ttf', size)
scratch = ImageDraw.Draw(Image.new('RGBA', (1, 1)))     # to measure without drawing


def key(d, x, y, label):
    """Draws one button at (x, y); returns where the next one goes."""
    f = bold(9 if len(label) > 2 else 10)
    if label in ROUND:
        d.ellipse([x, y, x + 15, y + 15], fill=KEY); w = 15
    else:
        w = max(15, int(d.textlength(label, font=f)) + 6)
        d.rounded_rectangle([x, y, x + w, y + 15], radius=4, fill=KEY)
    d.text((x + w / 2, y + 8), label, font=f, fill=INK, anchor='mm')
    return x + w + 2


def keys(d, x, y, labels):
    for k in labels:
        x = key(d, x, y, k)
    return x


for name, card in CARDS.items():                # one card for now; more can be added the same way
    for lang in ('en', 'fr'):
        t, size = card[lang], card['size']
        im = Image.new('RGBA', (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
        rows = max(len(r) for _, r in t['cols'])
        x0, y0, x1 = 5, 6, W - 5                                    # the card, as tall as its longest column
        y1 = y0 + 44 + 19 * rows + (18 if 'note' in t else 4)
        d.rounded_rectangle([x0, y0, x1, y1], radius=9, fill=CARD, outline=LINE, width=1)
        tx = keys(d, x0 + 12, y0 + 8, t['title'][0])
        d.text((tx + (3 if t['title'][0] else 0), y0 + 16), t['title'][1], font=bold(13), fill=INK, anchor='lm')
        ck, ctext = t['close']                                      # "SELECT close", right of the title
        fx = x1 - 12 - d.textlength(ctext, font=reg(11))
        d.text((fx, y0 + 16), ctext, font=reg(11), fill=MUTED, anchor='lm')
        keys(d, fx - keys(scratch, 0, 0, ck) - 1, y0 + 8, ck)
        for c, (head, col) in enumerate(t['cols']):
            cx = x0 + 12 + c * card['col2']
            d.text((cx, y0 + 34), head, font=bold(9), fill=MUTED, anchor='lm')
            lx = cx + max(keys(scratch, 0, 0, k) for k, _ in col) + 4  # labels line up in each column
            for i, (k, label) in enumerate(col):
                y = y0 + 44 + i * 19
                keys(d, cx, y, k)
                d.text((lx, y + 8), label, font=reg(size), fill=INK, anchor='lm')
                if lx + d.textlength(label, font=reg(size)) > (x1 - 3 if c else cx + card['col2'] - 4):
                    print(f'warning ({name}, {lang}): "{label}" is too long for its column')
        if 'note' in t:
            d.text((x0 + 12, y1 - 10), t['note'], font=reg(9), fill=MUTED, anchor='lm')
        im.save(os.path.join(HERE, f'{name}-card-{lang}.png'), optimize=True)
        print('saved', f'{name}-card-{lang}.png')
