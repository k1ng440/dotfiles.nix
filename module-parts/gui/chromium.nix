{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.chromium ];

      programs.chromium = {
        enable = true;

        extensions = [
          # uBlock Origin
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # SponsorBlock
          "mnjggcdmjocbbbhaepdhchncahnbgone"
          # Dark Reader
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          # Bitwarden
          "nngceckbapebfimnlniiiahkandclblb"
          # Return YouTube Dislike
          "gebbhagfogifgggkldgodflihgfeippi"
        ];
      };

      custom.persist = {
        home.directories = [
          ".cache/chromium"
          ".config/chromium"
        ];
      };
    };
}
