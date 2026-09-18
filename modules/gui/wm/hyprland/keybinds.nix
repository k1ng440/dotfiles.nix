{
  lib,
  self,
  ...
}:
{
  flake.modules.nixos.wm =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.custom.hardware) monitors;
      inherit (self.libCustom.generators) lua;
      q = lua.quote;

      mod = "SUPER";

      # old dispatcher names -> new hl.dsp.* tables
      # https://wiki.hypr.land/configuring/core/dispatchers/
      direction = {
        l = "left";
        r = "right";
        u = "up";
        d = "down";
        left = "left";
        right = "right";
        up = "up";
        down = "down";
      };

      dsp = rec {
        close = "hl.dsp.window.close()";
        exec = cmd: "hl.dsp.exec_cmd(${q cmd})";
        float = ''hl.dsp.window.float({ action = "toggle" })'';
        center = "hl.dsp.window.center()";
        groupToggle = "hl.dsp.group.toggle()";
        cycleNext = "hl.dsp.window.cycle_next()";
        moveFocus = d: ''hl.dsp.focus({ direction = "${direction.${d}}" })'';
        moveWindow = d: ''hl.dsp.window.move({ direction = "${direction.${d}}" })'';
        focusMonitor = d: ''hl.dsp.focus({ monitor = "${direction.${d}}" })'';
        moveWorkspaceToMonitor = d: ''hl.dsp.workspace.move({ monitor = "${direction.${d}}" })'';
        workspace = ws: "hl.dsp.focus({ workspace = ${ws} })";
        workspaceNamed = ws: workspace (q ws);
        moveToWorkspace = ws: "hl.dsp.window.move({ workspace = ${ws} })";
        moveToWorkspaceNamed = ws: moveToWorkspace (q ws);
        resize = x: y: "hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, relative = true })";
        fullscreen = mode: ''hl.dsp.window.fullscreen({ mode = "${mode}", action = "toggle" })'';
      };

      bind = keys: dispatcher: {
        inherit keys;
        dsp = dispatcher;
      };

      dms = call: dsp.exec "dms ipc call ${call}";

      workspaceBinds = lib.flatten (
        self.libCustom.mapWorkspaces (args: [
          (bind "${mod} + ${args.key}" (dsp.workspace args.workspace))
          (bind "${mod} + SHIFT + ${args.key}" (dsp.moveToWorkspace args.workspace))
        ]) monitors
      );
    in
    {
      custom.programs.hyprland.binds = [
        # --- Core System & UI ---
        (bind "ALT + F4" dsp.close)
        (bind "${mod} + Q" dsp.close)
        (bind "${mod} + BackSpace" dsp.close)
        (bind "CTRL + ALT + Delete" (dms "powermenu toggle"))
        (bind "${mod} + A" (dms "bar toggle"))
        (bind "${mod} + SHIFT + A" (dsp.exec "noctalia-reload"))
        (bind "${mod} + CTRL + V" (dms "clipboard toggle"))
        (bind "${mod} + N" (dms "notifications toggle"))
        (bind "${mod} + apostrophe" (dms "wallpaperCarousel toggle"))

        # --- Launcher & Files ---
        (bind "${mod} + Return" (dsp.exec "ghostty"))
        (bind "${mod} + SHIFT + Return" (dms "spotlight toggle"))
        (bind "${mod} + E" (dsp.exec "nemo ${config.hj.directory}/Downloads"))
        (bind "${mod} + SHIFT + E" (dsp.exec "ghostty -e yazi ${config.hj.directory}/Downloads"))

        # --- Layout & Utility ---
        (bind "${mod} + G" dsp.float)
        (bind "${mod} + C" dsp.center)
        (bind "${mod} + T" dsp.groupToggle)

        # --- Window Management (HJKL) ---
        (bind "${mod} + H" (dsp.moveFocus "l"))
        (bind "${mod} + L" (dsp.moveFocus "r"))
        (bind "${mod} + J" (dsp.moveFocus "d"))
        (bind "${mod} + K" (dsp.moveFocus "u"))
        (bind "${mod} + SHIFT + H" (dsp.moveWindow "l"))
        (bind "${mod} + SHIFT + L" (dsp.moveWindow "r"))
        (bind "${mod} + SHIFT + J" (dsp.moveWindow "d"))
        (bind "${mod} + SHIFT + K" (dsp.moveWindow "u"))

        # --- Navigation ---
        (bind "${mod} + grave" dsp.cycleNext)
        (bind "${mod} + Tab" (dsp.workspaceNamed "previous"))

        # --- Browser (Helium) ---
        (bind "${mod} + W" (dsp.exec "helium"))
        (bind "${mod} + SHIFT + W" (dsp.exec "helium --incognito"))

        # --- Monitor Navigation (Alt + hjkl) ---
        (bind "${mod} + ALT + H" (dsp.focusMonitor "l"))
        (bind "${mod} + ALT + J" (dsp.focusMonitor "d"))
        (bind "${mod} + ALT + K" (dsp.focusMonitor "u"))
        (bind "${mod} + ALT + L" (dsp.focusMonitor "r"))

        # --- Monitor Movement (Alt + Shift + hjkl) ---
        (bind "${mod} + ALT + SHIFT + H" (dsp.moveWorkspaceToMonitor "l"))
        (bind "${mod} + ALT + SHIFT + J" (dsp.moveWorkspaceToMonitor "d"))
        (bind "${mod} + ALT + SHIFT + K" (dsp.moveWorkspaceToMonitor "u"))
        (bind "${mod} + ALT + SHIFT + L" (dsp.moveWorkspaceToMonitor "r"))

        # --- Monitor Navigation (Alt + Arrows) ---
        (bind "${mod} + ALT + Left" (dsp.focusMonitor "l"))
        (bind "${mod} + ALT + Down" (dsp.focusMonitor "d"))
        (bind "${mod} + ALT + Up" (dsp.focusMonitor "u"))
        (bind "${mod} + ALT + Right" (dsp.focusMonitor "r"))

        # --- Monitor Movement (Alt + Shift + Arrows) ---
        (bind "${mod} + ALT + SHIFT + Left" (dsp.moveWorkspaceToMonitor "l"))
        (bind "${mod} + ALT + SHIFT + Down" (dsp.moveWorkspaceToMonitor "d"))
        (bind "${mod} + ALT + SHIFT + Up" (dsp.moveWorkspaceToMonitor "u"))
        (bind "${mod} + ALT + SHIFT + Right" (dsp.moveWorkspaceToMonitor "r"))

        # --- Shaping & Resizing (Arrows) ---
        (bind "${mod} + Left" (dsp.resize (-50) 0))
        (bind "${mod} + Right" (dsp.resize 50 0))
        (bind "${mod} + Up" (dsp.resize 0 (-50)))
        (bind "${mod} + Down" (dsp.resize 0 50))
        (bind "${mod} + F" (dsp.fullscreen "fullscreen"))
        (bind "${mod} + Z" (dsp.fullscreen "maximized"))

        # --- Workspaces ---
        (bind "${mod} + mouse_down" (dsp.workspaceNamed "e+1"))
        (bind "${mod} + mouse_up" (dsp.workspaceNamed "e-1"))

        # --- Screenshot ---
        (bind "Print" (dsp.exec "dms screenshot"))
        (bind "SHIFT + Print" (dsp.exec "dms screenshot --stdout | ${lib.getExe pkgs.satty} -f -"))

        # --- Audio (works while locked, old bindl) ---
        {
          keys = "XF86AudioLowerVolume";
          dsp = dsp.exec "pamixer -d 5";
          flags.locked = true;
        }
        {
          keys = "XF86AudioRaiseVolume";
          dsp = dsp.exec "pamixer -i 5";
          flags.locked = true;
        }
        {
          keys = "XF86AudioMute";
          dsp = dsp.exec "pamixer -t";
          flags.locked = true;
        }
      ]
      ++ workspaceBinds;
    };
}
