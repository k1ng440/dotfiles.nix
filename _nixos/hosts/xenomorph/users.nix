{ inputs, pkgs, ... }:
{
  users.mutableUsers = false;
  users.users.k1ng.packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.neovim
    pkgs.vim
    pkgs.firefox
    pkgs.rofi
  ];

  users.groups.k1ng = {
    gid = 1000;
  };

  users.users.k1ng = {
    uid = 1000;
    group = "k1ng";
    shell = pkgs.fish;
    isNormalUser = true;
    createHome = true;
    home = "/home/k1ng";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBKYBN4nrD/zxmIuuXvwqU3lqJPvjIHDs2fXOvq9ZKaglkNCK2p223siEMmOhN7qPZ+JKVPo0/oOrEQ8y/ovVbFgAAAAEc3NoOg== contact@iampavel.dev"
    ];
    /**
      * Generated with mkpasswd -m sha512crypt
      *
    */
    hashedPassword = "$6$mpjxKVszqmYBd.uZ$3SbGSwjAqK1sK8.YxIo5u2pPBH9hiSceda4p2QhRS0j2Slbb0TkNns2PpBiIRa4lFMx3l4S7jP9IWGotFUpDP0";
  };
}
