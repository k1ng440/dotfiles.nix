{
  flake.modules.nixos.core =
    { pkgs, ... }:
    let
      terminfo-sync = pkgs.writeShellApplication {
        name = "terminfo-sync";
        runtimeInputs = [ pkgs.ncurses ];
        text = builtins.readFile ./terminfo-sync.sh;
      };
    in
    {
      environment.systemPackages = [ terminfo-sync ];
    };
}
