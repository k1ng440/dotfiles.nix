{
  config,
  username,
  hostname,
  ...
}:
{
  users.users.${username} = {
    description = "Asaduzzaman Pavel";
    # mkpasswd -m sha-512
    hashedPasswordFile = config.sops.secrets."${hostname}/hashed_password_file".path;
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
