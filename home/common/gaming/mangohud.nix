_: {
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    settings = {
      # Performance and stats
      cpu_stats = true;
      cpu_temp = true;
      gpu_stats = true;
      gpu_temp = true;
      ram = true;
      vram = true;
      fps = true;
      frametime = true;
      frame_timing = true;

      # Visuals
      text_outline = true;
      text_outline_thickness = 1.0;

      # Layout
      hud_no_margin = true;
      table_columns = 3;

      # Limits
      fps_limit = [
        0
        60
        120
        144
      ]; # Cycle through these limits with Shift_L+F1

      # Toggles
      toggle_hud = "Shift_L+F12";
      toggle_fps_limit = "Shift_L+F1";
    };
  };
}
