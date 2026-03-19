{
  inputs,
  config,
  pkgs,
  ...
}:
let
  sopsFolder = (builtins.toString inputs.nix-secrets) + "/sops";
in
{
  sops.secrets = {
    "keys/atuin" = {
      sopsFile = "${sopsFolder}/shared.yaml";
      # owner = config.machine.username;
      # inherit (config.users.users.${config.machine.username}) group;
    };
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    # flags = [ "--disable-up-arrow" ];
    package = pkgs.atuin;
    settings = {
      auto_sync = false;
      dialect = "us";
      key_path = config.sops.secrets."keys/atuin".path;
      show_preview = true;
      style = "compact";
      sync_frequency = "1h";
      sync_address = "https://api.atuin.sh";
      update_check = false;
    };
  };
}
