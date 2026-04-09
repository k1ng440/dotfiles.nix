{
  flake.modules.nixos.core =
    { pkgs, ... }:
    let
      gcm = pkgs.writeShellApplication {
        name = "gcm";
        runtimeInputs = [
          pkgs.git
          pkgs.opencode
        ];
        text = builtins.readFile ./gcm.sh;
      };
    in
    {
      environment.systemPackages = [ gcm ];
    };
}
