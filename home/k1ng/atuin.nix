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
    };
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    package = pkgs.atuin;
    settings = {
      auto_sync = true;
      dialect = "uk";
      key_path = config.sops.secrets."keys/atuin".path;
      show_preview = true;
      style = "compact";
      sync_frequency = "1h";
      sync_address = "https://api.atuin.sh";
      update_check = false;
    };
  };
}
