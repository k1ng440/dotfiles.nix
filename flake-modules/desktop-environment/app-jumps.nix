/*
  *
  Home manager and NixOS modules that configures xremap and hyprland to enable
  pressing capslock+$key or hyper+$key to jump to specific apps.
*/
let
  appMap = {
    # E is for Emacs
    e = "Emacs";
    # B is for browser
    b = "firefox";
    # T is for terminal
    # This has to be the class, so there's no simple way to get this. Kitty
    # just so happens to have same pname and class.
    t = "kitty";
  };
in
{
  nixosModule =
    {
      inputs,
      lib,
      ...
    }:
    {
      services.xremap.config = {
        virtual_modifiers = [ "F18" ];

        imports = [
          inputs.xremap-flake.nixosModules.default
        ];

        modmap = [
          {
            # Global remap CapsLock to emit F18 when held
            name = "Global";
            remap."CapsLock" = {
              held = "F18";
              alone = "Esc";
              alone_timeout_millis = 250;
            };
          }
        ];

        keymap = [
          {
            name = "Remap hyper key";
            # Needs explicit bindings it seems. Maybe accept F18 as modifier in Hyprland?
            # Basically produces bindings like "F18-e" = "SHIFT-C-M-SUPER-e"
            # These are later handled by hyprland
            remap = lib.mapAttrs' (name: _: lib.nameValuePair "F18-${name}" "SHIFT-C-M-SUPER-${name}") appMap;
          }
        ];
      };
    };
  homeManagerModule =
    {
      inputs,
      srvLib,
      ...
    }:
    let
      inherit (srvLib) lib Hyper mainMod;
    in
    {
      imports = [
        inputs.xremap-flake.homeManagerModules.default
      ];

      wayland.windowManager.hyprland.myBinds = lib.mapAttrs' (
        name: value:
        lib.nameValuePair "${Hyper}+${name}" {
          mod = mainMod;
          dispatcher = "focuswindow";
          arg = "^(${value})$";
          description = "Focus '${value}' window";
        }
      ) appMap;
    };
}
