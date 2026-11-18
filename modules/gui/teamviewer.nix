{
  flake.modules.nixos.gui =
    {
      pkgs,
      ...
    }:
    let
      # patchelf 0.19.2 relocates .dynamic into the read-only LOAD segment of
      # these non-PIE binaries, so ld.so segfaults writing DT_DEBUG.
      # https://github.com/NixOS/nixpkgs/issues/576412
      teamviewer = pkgs.teamviewer.overrideAttrs (old: {
        patchelfFlags = (old.patchelfFlags or [ ]) ++ [
          "--page-size"
          "2097152"
        ];
      });
    in
    {
      services.teamviewer = {
        enable = true;
        package = teamviewer;
      };

      custom.persist.root.directories = [
        "/var/lib/teamviewer"
        "/var/log/teamviewer"
      ];

      custom.persist.home.directories = [
        ".config/teamviewer"
        ".local/share/teamviewer15"
      ];
    };
}
