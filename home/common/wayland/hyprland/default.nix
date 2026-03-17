{ pkgs, machine, ... }:
{
  imports = [
    ./animations-end4.nix
    ./binds.nix
    ./hyprland.nix
    ./pyprland.nix
    ./windowrules.nix
    ./scripts
  ];

  home.packages = [
    (import ./hyprgamemode.nix { inherit pkgs machine; })
  ];

  systemd.user.services.hypr-gamemode =
    let
      hyprgamemode = import ./hyprgamemode.nix { inherit pkgs machine; };
    in
    {
      Unit.Description = "Optimize Hyprland for Gaming";
      Service = {
        Type = "oneshot";
        ExecStart = "${hyprgamemode}/bin/hyprgamemode on";
        ExecStop = "${hyprgamemode}/bin/hyprgamemode off";
        RemainAfterExit = true;
      };
    };
}
