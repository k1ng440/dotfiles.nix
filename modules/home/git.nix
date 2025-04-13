{config, ...}:
let
  userName = config.hostSpec.userFullName;
  userEmail = config.hostSpec.email;
in {
  programs.git = {
    inherit userName userEmail;
    enable = true;
  };
}
