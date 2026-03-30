{
  flake.modules.nixos.wm =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wayfreeze
        slurp
        grim
        swappy
        libnotify
      ];
    };
}
