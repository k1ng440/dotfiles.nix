{
  pkgs,
  config,
  lib,
  ...
}:
let
  homeEval = builtins.tryEval config.machine.home;
  machineDefined = homeEval.success;
in
{
  programs.nh = lib.mkIf machineDefined {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "${homeEval.value}/nix-config";
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
