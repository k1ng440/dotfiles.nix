_: {
  perSystem =
    { pkgs, ... }:
    {
      packages.screenshot-tool = pkgs.writeShellApplication {
        name = "screenshot-tool";
        runtimeInputs = with pkgs; [
          grim
          slurp
          wl-clipboard
          wayfreeze
          rofi
          satty
          imv
          tesseract
          curl
          libnotify
        ];
        text = builtins.readFile ./screenshot-tool.sh;
      };
    };

  flake.modules.nixos.wm =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) screenshot-tool;
        })
      ];

      environment.systemPackages = with pkgs; [
        screenshot-tool
      ];
    };
}
