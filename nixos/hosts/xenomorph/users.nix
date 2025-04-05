{pkgs, ...}: {
  users.users.k1ng = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBKYBN4nrD/zxmIuuXvwqU3lqJPvjIHDs2fXOvq9ZKaglkNCK2p223siEMmOhN7qPZ+JKVPo0/oOrEQ8y/ovVbFgAAAAEc3NoOg== contact@iampavel.dev"
    ];
  };
}
