{ config, inputs, lib, ... }:
let
  sopsFolder = (builtins.toString inputs.nix-secrets) + "/sops";
  msmtpCfg = config.hostSpec.msmtp;
in
{
  config = lib.mkIf config.hostSpec.enableMsmtp {
    sops.secrets = {
      "passwords/msmtp" = {
        sopsFile = "${sopsFolder}/shared.yaml";
        owner = config.users.users.${config.hostSpec.username}.name;
        inherit (config.users.users.${config.hostSpec.username}) group;
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
        from = config.hostSpec.email.notifier;
        logfile = "~/.msmtp.log";
      };
    };
  };
}
