{
  configs,
  username,
  hostname,
  ...
}:
let
  test = builtins.trace configs.sops.secrets."${hostname}".hashed_password_file;
in
{
  users.users.${username} = {
    description = "Asaduzzaman Pavel";
    # mkpasswd -m sha-512
    hashedPasswordFile = test.path;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "bluetooth"
      "docker"
      "libvirt"
    ];
  };
}
