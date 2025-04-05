{pkgs, ...}: let
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [coreutils-full];
    text = builtins.readFile ./${name}.sh;
  };
in {
  home.packages = with pkgs; [shellApplication];
}
