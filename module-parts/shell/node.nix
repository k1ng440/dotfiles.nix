_: {
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    {
      environment = {
        systemPackages = [
          pkgs.nodejs_24
          pkgs.node-gyp
        ];
      };

      environment.interactiveShellInit = ''
        export PATH="$PATH:${config.hj.directory}/.npm-global/bin"
        export NODE_PATH="${config.hj.directory}/.npm-global/lib/node_modules"
      '';

      programs.fish.interactiveShellInit = ''
        set -x PATH $PATH ${config.hj.directory}/.npm-global/bin
        set -x NODE_PATH ${config.hj.directory}/.npm-global/lib/node_modules
      '';

      custom.persist = {
        home.directories = [ ".npm-glgobal" ];
      };
    };
}
