// Pi Tin faceplate v3 + LED pockets, light tunnels and reinforcement collars.
// faceplate_v3_with_led_pockets.stl is this model already rendered; this file is only
// needed to re-make it (for example after editing v3.stl).
// Open in OpenSCAD with the three STL files in the same folder, press F6 (render),
// then File > Export > STL.
// Order matters: add the collars first, then subtract the cutter. The collars reach
// 0.15 mm into the pockets so that no thin sliver is left between collar and pocket.
difference() {
  union() {
    import("v3.stl", convexity=10);
    import("faceplate_led_collars.stl", convexity=10);
  }
  import("faceplate_led_cutter.stl", convexity=10);
}
