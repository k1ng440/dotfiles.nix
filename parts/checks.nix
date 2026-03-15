{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ../.;
        hooks = {
          nixfmt.enable = true;
          nil.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      };

      formatter = pkgs.writeShellScriptBin "pre-commit-run" ''
        ${pkgs.lib.getExe config.checks.pre-commit-check.config.package} run --all-files --config ${config.checks.pre-commit-check.config.configFile}
      '';
    };
}
