_: {
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment = {
        systemPackages = [
          pkgs.nodejs_24
          pkgs.node-gyp
        ];

        variables = {
          PATH = [ /* sh */ "\${config.hj.directory}/.npm-global/bin" ];
          NODE_PATH = /* sh */ "\${config.hj.directory}/.npm-global/lib/node_modules";
        };
      };

      custom.programs.print-config = {
        # TODO: Set the path
      };
    };
}
