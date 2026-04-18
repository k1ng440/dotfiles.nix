{
  flake.modules.nixos.core =
    { pkgs, ... }:
    let
      gcm = pkgs.writeShellApplication {
        name = "gcm";
        runtimeInputs = [
          pkgs.git
        ];
        text = builtins.readFile ./gcm.sh;
      };
    in
    {
      environment.systemPackages = [ gcm ];
    };
}
