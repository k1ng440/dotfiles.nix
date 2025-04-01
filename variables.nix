let
  username = "k1ng";
  homeDirectory = builtins.toPath "/home/${username}";
in {
  inherit username;

  homeDirectory = {
    path = homeDirectory;
    directories = [
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
    ];
  };

  git = {
    username = "k1ng";
    email = "contact@iampavel.dev";
  };

  # Change me.
  dotfilesLocation = homeDirectory + (builtins.toPath "/nix-config");

  system = "x86_64-linux";
  stateVersion = "24.11";
}
