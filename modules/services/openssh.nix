{
  flake.modules.nixos.core = _: {
    services.openssh = {
      enable = true;
      # hostKeys = [
      # {
      #   path = builtins.trace "wtf" "/persist/etc/ssh/ssh_host_ed25519_key";
      #   type = "ed25519";
      # }
      # {
      #   path = "/persist/etc/ssh/ssh_host_rsa_key";
      #   type = "rsa";
      #   bits = 4096;
      # }
      # ];
    };
  };
}
