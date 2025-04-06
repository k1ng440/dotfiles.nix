let
  username = "k1ng";
  homeDirectory = builtins.toPath "/home/${username}";
  timeZone = "Asia/Dhaka";
in {
  inherit username timeZone;

  homeDirectory = {
    path = homeDirectory;
    directories = ["Documents" "Downloads" "Music" "Pictures" "Videos"];
  };

  initialUserPassword = "changeme";

  git = {
    username = "k1ng";
    email = "contact@iampavel.dev";
  };

  dotfilesLocation = homeDirectory + (builtins.toPath "/nix-config");

  nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  stateVersion = "24.11";
}
