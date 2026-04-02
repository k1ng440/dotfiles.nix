{
  flake.modules.nixos.gui =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.chromium ];

      programs.chromium = {
        # NOTE: programs.chromium.enable does not install any package!, it only creates policy files
        enable = true;

        extensions = [
          "nlipoenfbbikpbjkfpfillcgkoblgpmj" # Awesome Screen Recorder
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
          "lioaeidejmlpffbndjhaameocfldlhin" # Redirector
          "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
          "pgbjifpikialeahbdendkjioeafbmfkn" # Tokyo Night Storm
          "nffaoalbilbmmfgbnbgppjihopabppdk" # Video Speed Controller
          "fcphghnknhkimeagdglkljinmpbagone" # YouTube Auto HD
          "jiaopdjbehhjgokpphdfgmapkobbnmjp" # Youtube-shorts block
          "fadndhdgpmmaapbmfcknlfgcflmmmieb" # FrankerFaceZ - twitch
        ];
      };

      custom = {
        programs = {
          which-key = {
            menus = {
              c = {
                desc = "Chromium";
                cmd = lib.getExe pkgs.chromium;
              };
            };
          };
        };
        persist = {
          home.directories = [
            ".cache/chromium"
            ".config/chromium"
          ];
        };
      };
    };
}
