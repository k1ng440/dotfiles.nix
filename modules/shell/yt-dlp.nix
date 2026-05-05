{
  inputs,
  lib,
  self,
  ...
}:
let
  mkFormat =
    height: "bestvideo[height<=?${toString height}][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best";
in
{
  perSystem =
    { pkgs, ... }:
    let
      source = (self.libCustom.nvFetcherSources pkgs).yt-dlp;
    in
    {
      packages.yt-dlp = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.yt-dlp.overrideAttrs source;
        flags = {
          "--add-metadata" = true;
          "--format" = mkFormat 720;
          "--no-mtime" = true;
          "--output" = "%(title)s.%(ext)s";
          "--sponsorblock-mark" = "all";
          "--windows-filenames" = true;
          "--extractor-args" = "youtube:player_client=default,-android_sdkless";
        };
      };
    };

  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) yt-dlp;
        })
      ];

      environment = {
        shellAliases = {
          yt = "yt-dlp";
          yt1080 = ''yt-dlp --format "${mkFormat 1080}"'';
          ytaudio = "yt-dlp --audio-format mp3 --extract-audio";
          ytsubonly = "yt-dlp --skip-download --write-subs";
          ytplaylist = "yt-dlp --output '%(playlist_index)d - %(title)s.%(ext)s'";
        };

        systemPackages = with pkgs; [
          yt-dlp
        ];
      };

      custom.programs.print-config = {
        yt-dlp = /* sh */ ''moor --lang sh "${lib.getExe pkgs.yt-dlp}"'';
      };
    };
}
