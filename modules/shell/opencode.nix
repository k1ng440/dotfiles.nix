{
  flake.modules.nixos.shell_opencode =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.opencode
      ];

      custom.persist = {
        home.directories = [
          ".config/opencode"
          ".local/share/opencode"
        ];
      };
    };
}
