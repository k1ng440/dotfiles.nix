{ config, pkgs, ... }:
{
  atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    package = pkgs.atuin;
    settings = {
      auto_sync = true;
      dialect = "uk";
      # key_path = config.sops.secrets.atuin_key.path;
      show_preview = true;
      style = "compact";
      sync_frequency = "1h";
      sync_address = "https://api.atuin.sh";
      update_check = false;
    };
  };
}
