{ config, ... }:
{
  # Set a temp password for use by minimal builds like installer and iso
  users.users.${config.hostSpec.username} = {
    isNormalUser = true;
    # This is a hashed version of the plain-text password "nixos" for use in the ISO. Even though,
    # the password is known, we use `hashedPassword` here instead of `password` to mitigate
    # occurrences of the latter not being used during build.
    hashedPassword = "$y$j9T$Ac.m5IZ6ku/nrqK9K9kBi1$lRHp3Xg4Vk7Ly/VAiv5d839VlwDRNt2w9ACMMKe8kR2";
    extraGroups = [ "wheel" ];
  };
}
