_: {
  flake.modules.nixos.shell_claude-code =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.claude-code
      ];

      custom.persist = {
        home.directories = [
          ".claude"
        ];
      };
    };
}
