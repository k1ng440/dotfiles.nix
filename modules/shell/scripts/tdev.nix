{
  flake.modules.nixos.core =
    { pkgs, ... }:
    let
      tdev = pkgs.writeShellApplication {
        name = "tdev";
        runtimeInputs = [
          pkgs.tmux
          pkgs.iproute2
        ];
        text = builtins.readFile ./tdev.sh;
      };
    in
    {
      environment.systemPackages = [ tdev ];
    };
}
