_: {
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.bun
      ];

      environment.interactiveShellInit = ''
        export BUN_INSTALL="${config.hj.directory}/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
      '';

      programs.fish.interactiveShellInit = ''
        set -x BUN_INSTALL ${config.hj.directory}/.bun
        set -x PATH $BUN_INSTALL/bin $PATH
      '';

      custom.persist = {
        home.directories = [ ".bun" ];
      };
    };
}
