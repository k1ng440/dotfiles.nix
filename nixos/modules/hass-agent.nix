{ ... }:
{
  users.users.hass-agent = {
    isSystemUser = true;
    group = "hass-agent";
    shell = "/run/current-system/sw/bin/bash";
    # openssh.authorizedKeys.keys = [
    # ];
  };

  users.groups.hass-agent = { };

  security.sudo.extraRules = [
    {
      users = [ "hass-agent" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl suspend";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
