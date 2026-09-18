{ inputs, lib, ... }:
let
  # ---------------------------------------------------------------------------------
  # Nix -> Lua generators for the Hyprland lua config.
  #
  # Hyprland >= 0.56 configures itself with lua (`hyprland.lua`) instead of the old
  # hyprlang `hyprland.conf` (the `.conf` fallback was removed on main, so it is gone
  # in the next release). See:
  #   https://wiki.hypr.land/configuring/core/
  #   https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
  # ---------------------------------------------------------------------------------
  lua = rec {
    # long bracket levels: [[ ]], [==[ ]==], ...
    bracketLevels = [
      ""
      "="
      "=="
      "==="
      "===="
      "====="
    ];

    # escape hatch: emit a raw lua expression instead of a quoted literal.
    # used for bind dispatchers (`hl.dsp.window.close()`), lua functions, ...
    raw = text: { __rawLua = text; };
    isRaw = v: lib.isAttrs v && v ? __rawLua;

    # long brackets keep backslashes (regexes) and quotes (shell commands) literal
    longBracket =
      s:
      let
        level = lib.findFirst (l: !(lib.hasInfix "]${l}]" s)) null bracketLevels;
      in
      if level == null then throw "lua.quote: cannot quote string: ${s}" else "[${level}[${s}]${level}]";

    quote =
      s:
      if
        lib.any (c: lib.hasInfix c s) [
          "\""
          "'"
          "\\"
          "\n"
        ]
      then
        longBracket s
      else
        ''"${s}"'';

    # nix renders floats with 6 decimals (1.0 -> "1.000000"), trim them
    formatFloat =
      v:
      let
        parts = lib.splitString "." (toString v);
        intPart = lib.head parts;
        stripTrailing =
          str: if lib.hasSuffix "0" str then stripTrailing (lib.removeSuffix "0" str) else str;
        frac = stripTrailing (if builtins.length parts > 1 then lib.last parts else "");
      in
      if frac == "" then "${intPart}.0" else "${intPart}.${frac}";

    isIdentifier = s: builtins.match "[a-zA-Z_][a-zA-Z0-9_]*" s != null;
    key = k: if isIdentifier k then k else "[${quote k}]";

    indent = n: lib.concatStrings (lib.genList (_: " ") (n * 2));

    toLua =
      depth: v:
      let
        pad = indent (depth + 1);
        self = indent depth;
      in
      if isRaw v then
        v.__rawLua
      else if v == null then
        "nil"
      else if lib.isBool v then
        (if v then "true" else "false")
      else if lib.isInt v then
        toString v
      else if lib.isFloat v then
        formatFloat v
      else if lib.isString v then
        quote v
      else if lib.isPath v then
        quote (toString v)
      else if lib.isList v then
        if v == [ ] then
          "{ }"
        else
          "{\n" + lib.concatMapStringsSep "\n" (e: "${pad}${toLua (depth + 1) e},") v + "\n${self}}"
      else if lib.isAttrs v then
        if v == { } then
          "{ }"
        else
          "{\n"
          + lib.concatMapStringsSep "\n" (n: "${pad}${key n} = ${toLua (depth + 1) v.${n}},") (
            lib.attrNames v
          )
          + "\n${self}}"
      else
        throw "lua.toLua: unsupported value of type ${builtins.typeOf v}";

    # hl.<fn>(<args...>)
    call = fn: args: "hl.${fn}(${lib.concatMapStringsSep ", " (toLua 0) args})";
    # hl.<fn>({ ... })
    tableCall = fn: attrs: call fn [ attrs ];
  };

  # a value that can appear anywhere in the generated lua config
  #
  # NB: no `submodule` branch here. A submodule branch would expose its
  # options as sub-options on every nested attrset, which breaks defining
  # `settings.deeply.nested.key = value` (the module system would look up
  # each intermediate path as an option). Raw lua (`lua.raw`) still works:
  # `{ __rawLua = ... }` is a valid attrset value and `toLua` emits it verbatim.
  luaValueType =
    let
      valueType =
        lib.types.nullOr (
          lib.types.oneOf [
            lib.types.bool
            lib.types.int
            lib.types.float
            lib.types.str
            lib.types.path
            (lib.types.attrsOf valueType)
            (lib.types.listOf valueType)
          ]
        )
        // {
          description = "Hyprland lua configuration value";
        };
    in
    valueType;

  hyprlandOptions = {
    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.package lib.types.path);
      default = [ ];
      description = ''
        List of Hyprland plugins to use. Can either be packages or
        absolute plugin paths.
      '';
    };

    # table passed to hl.config(), see https://wiki.hypr.land/configuring/core/config-options/
    settings = lib.mkOption {
      type = lib.types.attrsOf luaValueType;
      default = { };
      description = ''
        Hyprland config options written in Nix, rendered as `hl.config({ ... })`.
        Nested attrsets become nested lua tables, lists become lua arrays.
        Values wrapped with `self.libCustom.generators.lua.raw` are emitted verbatim.
      '';
      example = lib.literalExpression ''
        {
          general = {
            gaps_in = 5;
            col.active_border = {
              colors = [ "rgba(89B4FAff)" "rgba(94E2D5ff)" ];
              angle = 45;
            };
          };
          decoration.shadow.offset = [ 0 5 ];
        }
      '';
    };

    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Monitor rules, rendered as `hl.monitor({ ... })`.";
    };

    workspaceRules = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Workspace rules, rendered as `hl.workspace_rule({ ... })`.";
    };

    windowRules = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Window rules, rendered as `hl.window_rule({ ... })`.";
    };

    layerRules = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Layer rules, rendered as `hl.layer_rule({ ... })`.";
    };

    devices = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Per device input config, rendered as `hl.device({ ... })`.";
    };

    gestures = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Gestures, rendered as `hl.gesture({ ... })`.";
    };

    curves = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf luaValueType);
      default = { };
      description = ''
        Animation curves (beziers/springs), rendered as `hl.curve("name", { ... })`.
        Must be declared before the animations that reference them.
      '';
      example = lib.literalExpression ''
        {
          md3_decel = {
            type = "bezier";
            points = [ [ 0.05 0.7 ] [ 0.1 1 ] ];
          };
        }
      '';
    };

    animations = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf luaValueType);
      default = [ ];
      description = "Animations, rendered as `hl.animation({ leaf = ..., ... })`.";
    };

    binds = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            keys = lib.mkOption {
              type = lib.types.str;
              description = ''
                Key combination, e.g. `"SUPER + SHIFT + Q"`, `"mouse:272"`,
                `"switch:Lid Switch"`.
              '';
            };
            dsp = lib.mkOption {
              type = lib.types.str;
              description = ''
                Raw lua dispatcher expression, e.g. `"hl.dsp.window.close()"`,
                or a lua function. See https://wiki.hypr.land/configuring/core/dispatchers/
              '';
            };
            flags = lib.mkOption {
              type = lib.types.attrsOf luaValueType;
              default = { };
              description = "Bind flags, e.g. `{ locked = true; mouse = true; }`.";
            };
          };
        }
      );
      default = [ ];
      description = "Keybinds, rendered as `hl.bind(keys, dsp, flags)`.";
    };

    execOnce = lib.mkOption {
      type = lib.types.listOf (
        lib.types.oneOf [
          lib.types.str
          (lib.types.submodule {
            options = {
              command = lib.mkOption {
                type = lib.types.str;
                description = "Command to execute.";
              };
              rules = lib.mkOption {
                type = lib.types.attrsOf luaValueType;
                default = { };
                description = ''
                  Window rule effects applied to the spawned process,
                  e.g. `{ workspace = "3 silent"; }`.
                '';
              };
            };
          })
        ]
      );
      default = [ ];
      description = ''
        Commands to run once on startup, rendered inside
        `hl.on("hyprland.start", function() ... end)`.
      '';
    };

    # named envVars because the wrapper modules already reserve `env`
    envVars = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables, rendered as `hl.env(name, value)`.";
    };

    extraLua = lib.mkOption {
      type = lib.types.listOf lib.types.lines;
      default = [ ];
      description = "Raw lua appended to the end of the generated config.";
    };

    # keep parity with the old `source=~/.config/hypr/hyprland.conf` behaviour:
    # a user local file can still override the nix generated config.
    userOverrides =
      lib.mkEnableOption "loading ~/.config/hypr/hyprland.lua on top of the generated config"
      // {
        default = true;
      };
  };

  # render the whole hyprland.lua
  generate =
    cfg:
    let
      section =
        title: lines:
        if lines == [ ] then "" else "\n---- ${title} ----\n" + lib.concatStringsSep "\n" lines;

      execOnce = lib.concatMap (
        entry:
        let
          command = if lib.isString entry then entry else entry.command;
          rules = if lib.isString entry then null else (if entry.rules == { } then null else entry.rules);
        in
        if rules == null then
          [ "hl.exec_cmd(${lua.quote command})" ]
        else
          [
            (lua.call "exec_cmd" [
              command
              rules
            ])
          ]
      ) cfg.execOnce;
    in
    lib.concatStringsSep "\n" (
      lib.filter (s: s != "") [
        "-- Generated by Nix, do not edit!"
        "-- https://wiki.hypr.land/configuring/core/"
        (section "environment" (
          lib.mapAttrsToList (
            n: v:
            lua.call "env" [
              n
              v
            ]
          ) cfg.envVars
        ))
        (section "plugins" (
          map (
            p:
            let
              entry = if lib.types.package.check p then "${p}/lib/lib${p.pname}.so" else p;
            in
            lua.call "plugin.load" [ entry ]
          ) cfg.plugins
        ))
        (section "monitors" (map (m: lua.tableCall "monitor" m) cfg.monitors))
        (section "workspace rules" (map (r: lua.tableCall "workspace_rule" r) cfg.workspaceRules))
        (section "curves" (
          lib.mapAttrsToList (
            n: c:
            lua.call "curve" [
              n
              c
            ]
          ) cfg.curves
        ))
        (section "animations" (map (a: lua.tableCall "animation" a) cfg.animations))
        (section "config" (lib.optional (cfg.settings != { }) (lua.tableCall "config" cfg.settings)))
        (section "gestures" (map (g: lua.tableCall "gesture" g) cfg.gestures))
        (section "devices" (map (d: lua.tableCall "device" d) cfg.devices))
        (section "window rules" (map (r: lua.tableCall "window_rule" r) cfg.windowRules))
        (section "layer rules" (map (r: lua.tableCall "layer_rule" r) cfg.layerRules))
        (section "keybinds" (
          map (
            b:
            lua.call "bind" (
              [
                b.keys
                (lua.raw b.dsp)
              ]
              ++ lib.optional (b.flags != { }) b.flags
            )
          ) cfg.binds
        ))
        (section "autostart" (
          lib.optional (execOnce != [ ]) ''
            hl.on("hyprland.start", function()
            ${lib.concatMapStringsSep "\n" (l: "  ${l}") execOnce}
            end)
          ''
        ))
        (section "user overrides" (
          lib.optional cfg.userOverrides ''
            -- optional local overrides (equivalent of the old `source=~/.config/hypr/hyprland.conf`)
            do
              local home = os.getenv("HOME")
              if home then
                pcall(require, home .. "/.config/hypr/hyprland")
              end
            end
          ''
        ))
        (section "extra" cfg.extraLua)
      ]
    )
    + "\n";
in
{
  flake.libCustom = {
    generators = {
      inherit lua;
      inherit generate;
    };
    types = {
      inherit luaValueType;
    };
  };

  flake.wrapperModules.hyprland = inputs.wrappers.lib.wrapModule (
    {
      config,
      wlib,
      pkgs,
      ...
    }:
    let
      hyprlandLuaText = generate config;
      checkedHyprlandLua = pkgs.runCommand "hyprland.lua" { } ''
        install -Dm644 ${pkgs.writeText "hyprland.lua" hyprlandLuaText} "$out"
        export HOME=$(mktemp -d)
        export XDG_RUNTIME_DIR=$(mktemp -d)
        ${lib.getExe config.package} --verify-config -c "$out"
      '';
    in
    {
      imports = [ wlib.modules.default ];

      options = hyprlandOptions // {
        "hyprland.lua" = lib.mkOption {
          type = wlib.types.file pkgs;
          default.path = checkedHyprlandLua;
          visible = false;
        };
      };

      config.package = lib.mkDefault pkgs.hyprland;
      config.passthru.providedSessions = config.package.passthru.providedSessions or [ ];
      config.filesToPatch = [
        "share/wayland-sessions/*.desktop"
      ];
      config.flags = {
        "--config" = toString config."hyprland.lua".path;
      };
    }
  );

  flake.modules.nixos.core = {
    options.custom = {
      programs.hyprland = hyprlandOptions;
    };
  };
}
