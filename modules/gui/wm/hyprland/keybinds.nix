{
  lib,
  self,
  ...
}:
{
  flake.modules.nixos.wm =
    {
      config,
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
        focusLast = "hl.dsp.focus({ last = true })";
        focusFloatingOrTiled = "function() return focus_floating_or_tiled() end";
        presetWidth = ''function() return cycle_preset_size("width") end'';
        presetHeight = ''function() return cycle_preset_size("height") end'';
        layout = msg: "hl.dsp.layout(${q msg})";
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

      bind = keys: description: dispatcher: {
        inherit keys description;
        dsp = dispatcher;
      };

      noctalia = call: dsp.exec "noctalia msg ${call}";

      workspaceBinds = lib.flatten (
        self.libCustom.mapWorkspaces (args: [
          (bind "${mod} + ${args.key}" "Focus workspace ${args.workspace}" (dsp.workspace args.workspace))
          (bind "${mod} + SHIFT + ${args.key}" "Move window to workspace ${args.workspace}" (
            dsp.moveToWorkspace args.workspace
          ))
        ]) monitors
      );

      baseBinds = [
        # --- Core System & UI ---
        (bind "ALT + F4" "Close window" dsp.close)
        (bind "${mod} + Q" "Close window" dsp.close)
        (bind "${mod} + BackSpace" "Close window" dsp.close)
        (bind "CTRL + ALT + Delete" "Session menu (logout, lock, ...)" (noctalia "panel-toggle session"))
        (bind "${mod} + A" "Toggle bar" (noctalia "bar-toggle"))
        (bind "${mod} + SHIFT + A" "Reload noctalia" (dsp.exec "noctalia-reload"))
        (bind "${mod} + CTRL + V" "Clipboard history" (noctalia "panel-toggle clipboard"))
        (bind "${mod} + N" "Notification center" (noctalia "panel-toggle control-center notifications"))
        (bind "${mod} + apostrophe" "Wallpaper picker" (noctalia "panel-toggle wallpaper"))

        # --- Launcher & Files ---
        (bind "${mod} + Return" "Terminal (ghostty)" (dsp.exec "ghostty"))
        (bind "${mod} + SHIFT + Return" "Application launcher" (noctalia "panel-toggle launcher"))
        (bind "${mod} + E" "File manager (Downloads)" (dsp.exec "nemo ${config.hj.directory}/Downloads"))
        (bind "${mod} + SHIFT + E" "Yazi in terminal (Downloads)" (
          dsp.exec "ghostty -e yazi ${config.hj.directory}/Downloads"
        ))

        # --- Hex dictation (command binds, no portal key needed) ---
        (bind "End" "Dictation toggle" (dsp.exec "hex dictation toggle"))
        (bind "ALT + SPACE" "Dictation toggle" (dsp.exec "hex dictation toggle"))
        (bind "F10" "Paste last dictation" (dsp.exec "hex paste-last"))

        # --- Layout & Utility ---
        (bind "${mod} + G" "Toggle floating" dsp.float)
        (bind "${mod} + SHIFT + G" "Focus floating/tiled window" dsp.focusFloatingOrTiled)
        (bind "${mod} + C" "Center window" dsp.center)
        (bind "${mod} + T" "Toggle window group" dsp.groupToggle)
        (bind "${mod} + V" "Toggle layout split" (dsp.layout "togglesplit"))

        # --- Window Management (HJKL) ---
        (bind "${mod} + H" "Focus left" (dsp.moveFocus "l"))
        (bind "${mod} + L" "Focus right" (dsp.moveFocus "r"))
        (bind "${mod} + J" "Focus down" (dsp.moveFocus "d"))
        (bind "${mod} + K" "Focus up" (dsp.moveFocus "u"))
        (bind "${mod} + SHIFT + H" "Move window left" (dsp.moveWindow "l"))
        (bind "${mod} + SHIFT + L" "Move window right" (dsp.moveWindow "r"))
        (bind "${mod} + SHIFT + J" "Move window down" (dsp.moveWindow "d"))
        (bind "${mod} + SHIFT + K" "Move window up" (dsp.moveWindow "u"))

        # --- Navigation ---
        (bind "${mod} + grave" "Focus last window" dsp.focusLast)
        (bind "${mod} + Tab" "Previous workspace" (dsp.workspaceNamed "previous"))
        (bind "${mod} + SHIFT + Tab" "Focus last window" dsp.focusLast)

        # --- Browser (Helium) ---
        (bind "${mod} + W" "Browser (helium)" (dsp.exec "helium"))
        (bind "${mod} + SHIFT + W" "Browser incognito" (dsp.exec "helium --incognito"))

        # --- Monitor Navigation (Alt + hjkl) ---
        (bind "${mod} + ALT + H" "Focus monitor left" (dsp.focusMonitor "l"))
        (bind "${mod} + ALT + J" "Focus monitor down" (dsp.focusMonitor "d"))
        (bind "${mod} + ALT + K" "Focus monitor up" (dsp.focusMonitor "u"))
        (bind "${mod} + ALT + L" "Focus monitor right" (dsp.focusMonitor "r"))

        # --- Monitor Movement (Alt + Shift + hjkl) ---
        (bind "${mod} + ALT + SHIFT + H" "Move workspace to monitor left" (dsp.moveWorkspaceToMonitor "l"))
        (bind "${mod} + ALT + SHIFT + J" "Move workspace to monitor down" (dsp.moveWorkspaceToMonitor "d"))
        (bind "${mod} + ALT + SHIFT + K" "Move workspace to monitor up" (dsp.moveWorkspaceToMonitor "u"))
        (bind "${mod} + ALT + SHIFT + L" "Move workspace to monitor right" (dsp.moveWorkspaceToMonitor "r"))

        # --- Monitor Navigation (Alt + Arrows) ---
        (bind "${mod} + ALT + Left" "Focus monitor left" (dsp.focusMonitor "l"))
        (bind "${mod} + ALT + Down" "Focus monitor down" (dsp.focusMonitor "d"))
        (bind "${mod} + ALT + Up" "Focus monitor up" (dsp.focusMonitor "u"))
        (bind "${mod} + ALT + Right" "Focus monitor right" (dsp.focusMonitor "r"))

        # --- Monitor Movement (Alt + Shift + Arrows) ---
        (bind "${mod} + ALT + SHIFT + Left" "Move workspace to monitor left" (
          dsp.moveWorkspaceToMonitor "l"
        ))
        (bind "${mod} + ALT + SHIFT + Down" "Move workspace to monitor down" (
          dsp.moveWorkspaceToMonitor "d"
        ))
        (bind "${mod} + ALT + SHIFT + Up" "Move workspace to monitor up" (dsp.moveWorkspaceToMonitor "u"))
        (bind "${mod} + ALT + SHIFT + Right" "Move workspace to monitor right" (
          dsp.moveWorkspaceToMonitor "r"
        ))

        # --- Shaping & Resizing (Arrows) ---
        (bind "${mod} + Left" "Resize left" (dsp.resize (-50) 0))
        (bind "${mod} + Right" "Resize right" (dsp.resize 50 0))
        (bind "${mod} + Up" "Resize up" (dsp.resize 0 (-50)))
        (bind "${mod} + Down" "Resize down" (dsp.resize 0 50))
        (bind "${mod} + R" "Cycle width preset" dsp.presetWidth)
        (bind "${mod} + SHIFT + R" "Cycle height preset" dsp.presetHeight)
        (bind "${mod} + F" "Fullscreen" (dsp.fullscreen "fullscreen"))
        (bind "${mod} + Z" "Maximize" (dsp.fullscreen "maximized"))

        # --- Workspaces ---
        (bind "${mod} + mouse_down" "Next workspace" (dsp.workspaceNamed "e+1"))
        (bind "${mod} + mouse_up" "Previous workspace" (dsp.workspaceNamed "e-1"))

        # --- Screenshot ---
        # noctalia owns the whole flow: `[shell.screenshot]` decides
        # save/copy and the directory, and its built-in editor replaces the
        # old `dms screenshot | satty` pipe.
        (bind "Print" "Screenshot region" (noctalia "screenshot-region"))
        (bind "SHIFT + Print" "Screenshot fullscreen (pick)" (noctalia "screenshot-fullscreen pick"))
        (bind "CTRL + SHIFT + Print" "Screenshot annotate" (noctalia "screenshot-annotate"))
        (bind "${mod} + SHIFT + S" "Screenshot fullscreen (all outputs)" (
          noctalia "screenshot-fullscreen all"
        ))

        # --- Audio (works while locked, old bindl) ---
        {
          keys = "XF86AudioLowerVolume";
          description = "Volume down";
          dsp = dsp.exec "pamixer -d 5";
          flags.locked = true;
        }
        {
          keys = "XF86AudioRaiseVolume";
          description = "Volume up";
          dsp = dsp.exec "pamixer -i 5";
          flags.locked = true;
        }
        {
          keys = "XF86AudioMute";
          description = "Mute";
          dsp = dsp.exec "pamixer -t";
          flags.locked = true;
        }
      ]
      ++ workspaceBinds;

      # Built from the merged bind list, so hyprland-only extras (backlight,
      # idle-lock, ...) show up without being restated here.
      cheatsheet =
        let
          allBinds = config.custom.programs.hyprland.binds ++ [
            {
              keys = "${mod} + SHIFT + slash";
              description = "Show this keybind cheatsheet";
            }
          ];
          desc = b: if b.description == null then "" else b.description;
          width = (lib.foldl' (n: b: lib.max n (lib.stringLength b.keys)) 0 allBinds) + 4;
          line =
            b:
            "${b.keys}${lib.concatStrings (lib.genList (_: " ") (width - lib.stringLength b.keys))}${desc b}";
        in
        pkgs.writeText "hyprland-keybinds.txt" ''
          Hyprland keybinds (Mod = Super)
          ${lib.concatLines (map line allBinds)}
        '';

      cheatsheetBind = ''
        hl.bind(${q "${mod} + SHIFT + slash"}, hl.dsp.exec_cmd(${q "ghostty -e less ${cheatsheet}"}), { description = ${q "Show keybind cheatsheet"} })
      '';
    in
    {
      custom.programs.hyprland = {
        extraLua = [
          ''
            -- niri's switch-focus-between-floating-and-tiling; focus the other kind
            function focus_floating_or_tiled()
              local window = hl.get_active_window()
              if window then
                hl.dispatch(hl.dsp.focus({ window = window.floating and "tiled" or "floating" }))
              end
            end
          ''
          ''
            -- niri's preset column width (Mod+R) / window height (Mod+SHIFT+R) cycles.
            -- Resizes the window to the next preset fraction of its monitor's size.
            local preset_widths = { 0.25, 0.5, 0.75 }
            local preset_heights = { 1 / 3, 1 / 2, 2 / 3 }

            function cycle_preset_size(axis)
              local window = hl.get_active_window()
              if not window or window.fullscreen then
                return
              end
              local current = window.size
              local monitor = window.monitor and window.monitor.size
              if not (current and monitor) then
                return
              end

              local presets, size, total
              if axis == "width" then
                presets, size, total = preset_widths, current.x, monitor.width
              else
                presets, size, total = preset_heights, current.y, monitor.height
              end

              local target = presets[1]
              local fraction = size / total
              for _, preset in ipairs(presets) do
                if preset > fraction + 0.01 then
                  target = preset
                  break
                end
              end

              local delta = math.floor(target * total - size)
              if axis == "width" then
                hl.dispatch(hl.dsp.window.resize({ x = delta, y = 0, relative = true }))
              else
                hl.dispatch(hl.dsp.window.resize({ x = 0, y = delta, relative = true }))
              end
            end
          ''
        ]
        ++ [ cheatsheetBind ];

        binds = baseBinds;
      };
    };
}
