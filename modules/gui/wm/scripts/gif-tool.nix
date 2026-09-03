_: {
  perSystem =
    { pkgs, ... }:
    {
      packages.gif-tool = pkgs.writeShellApplication {
        name = "gif-tool";
        runtimeInputs = with pkgs; [
          gpu-screen-recorder
          gifski
          ffmpeg
          libnotify
          procps
          slurp
          wayfreeze
        ];
        text = builtins.readFile ./gif-tool.sh;
      };
    };

  flake.modules.nixos.wm =
    { pkgs, lib, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) gif-tool;
        })
      ];

      programs.gpu-screen-recorder.enable = true;

      custom.programs.which-key.menus.g = {
        desc = "GIF Capture";
        cmd = lib.getExe pkgs.gif-tool;
      };

      environment.systemPackages = with pkgs; [
        gif-tool
      ];
    };
}
