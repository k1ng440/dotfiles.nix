{
  config,
  inputs,
  lib,
  ...
}:
let
  sopsFolder = (builtins.toString inputs.nix-secrets) + "/sops";

  msmtpCfg = builtins.trace config.machine.msmtp.config config.machine.msmtp.config;
in
{
  options.hostConfig.msmtp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable msmtp";
    };
  };

  config = lib.mkIf config.hostConfig.msmtp.enable {
    sops.secrets = {
      "passwords/msmtp" = {
        sopsFile = "${sopsFolder}/shared.yaml";
        owner = config.users.users.${config.machine.username}.name;
        inherit (config.users.users.${config.machine.username}) group;
      };
    };

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      accounts.default = {
        auth = true;
        host = msmtpCfg.host;
        port = msmtpCfg.port;
        user = msmtpCfg.username;
        passwordeval = "cat ${config.sops.secrets."passwords/msmtp".path}";
        tls = msmtpCfg.tls;
        tls_starttls = msmtpCfg.tls;
        from = config.machine.email.notifier;
        logfile = "~/.msmtp.log";
      };
    };

    programs.msmtp.defaults = {
      aliases = "/etc/aliases";
    };

    environment.etc = {
      "aliases" = {
        text = ''
          root: ${config.machine.email.notifier}
          ${config.machine.username}: ${config.machine.email.user}
        '';
        mode = "0644";
      };
    };
  };
}
