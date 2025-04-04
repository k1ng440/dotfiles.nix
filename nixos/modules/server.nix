{
  pkgs,
  lib,
  ...
}: {
  # Common server packages
  environment.systemPackages = with pkgs; [
    bat
    bottom
    curl
    dnsutils
    git
    helix
    htop
    httpie
    jq
    ripgrep
  ];

  # List of available shells
  environment.shells = with pkgs; [
    bash
    zsh
  ];

  # Print the URL instead
  environment.variables.BROWSER = "echo";

  # Use helix as the default editor
  environment.variables.EDITOR = "hx";

  # No need for sound on a server
  sound.enable = false;

  # Use firewalls everywhere
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  # Disable IPV6
  networking.enableIPv6 = false;

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;

  # We don't want to request password for sudoers
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Use Cloudflare DNS
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  # Use zsh as default shell
  users.defaultUserShell = pkgs.zsh;

  # Define default system version
  system.stateVersion = "24.11";
}
