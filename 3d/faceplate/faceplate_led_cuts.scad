// Pi Tin faceplate v3 + LED pockets, light tunnels and reinforcement collars.
// faceplate_v3_with_led_pockets.stl is this model already rendered; this file is only
// needed to re-make it (for example after editing v3.stl).
// Open in OpenSCAD with the five STL files in the same folder, press F6 (render),
// then File > Export > STL.
// Order matters: add the collars first, then subtract the cutter and the antenna pocket, then add the key tabs
// back. The collars reach 0.15 mm into the pockets so that no thin sliver is left between collar and pocket.
union() {
difference() {
  union() {
    import("v3.stl", convexity=10);
    import("faceplate_led_collars.stl", convexity=10);
    // Fills the bits of the ABXY LED chambers that the collars leave outside the cutter (and closes D3's collar,
    // open on its lower-left side), so that each pocket is exactly the cutter's shape, like the D-pad ones.
    import("faceplate_pocket_fill.stl", convexity=10);
    // microSD closure: v3.stl closes the card opening with a 0.8 mm skin (Y 3.8-4.6).
    // This block thickens it to 1.7 mm (from Y 2.9), which prints flatter. It leaves 2.9 mm
    // above the Orange Pi for the card and its slot; the rib next to it already stops at 2.0 mm.
    translate([83.55, 2.9, 10.9]) cube([5.43, 1.1, 13.6]);
    // Skin panels thickened from 0.8 to 1.7 mm (also from Y 2.9). The main board's front only has the
    // buttons, LEDs and speaker (the USB-C's shell legs, which come through from the back, must not stick out
    // more than 1.5 mm). Left as they were: the button rings, the LED pockets and light tunnels (0.5 mm
    // around them), the Start/Select and side-button switches, and the speaker.
    // Over the Orange Pi, the panels above the HDMI and the Wi-Fi module (antenna cable) stay 0.8 mm.
    import("faceplate_thickening.stl", convexity=10);
  }
  import("faceplate_led_cutter.stl", convexity=10);
  // Pocket over the Orange Pi's antenna connector (IPEX-4 / MHF4; up to Y 3.4, room for the plug and cable),
  // and a channel from it into the panel over the Wi-Fi module, where the flex antenna goes.
  translate([19.6, -1, 7.1]) cube([4.0, 4.4, 3.35]);
  translate([20.9, -1, 10.4]) cube([2.7, 4.4, 0.2]);
}
// Key tabs of B (left and right) and Y (bottom): the light tunnels end where they are, so the cutter took their
// lower 0.8 mm. They go back to v3's shape (from Y 1.8); light still passes beside and under them.
translate([22.875, 1.8, 31.55]) cube([0.6902, 0.9, 0.6]);
translate([14.4348, 1.8, 31.55]) cube([0.6902, 0.9, 0.6]);
translate([26.2, 1.8, 34.7848]) cube([0.6, 0.9, 0.6902]);
}
