{
  user = {
    hashedPassword = "$6$mpjxKVszqmYBd.uZ$3SbGSwjAqK1sK8.YxIo5u2pPBH9hiSceda4p2QhRS0j2Slbb0TkNns2PpBiIRa4lFMx3l4S7jP9IWGotFUpDP0";
    ssh-key = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBKYBN4nrD/zxmIuuXvwqU3lqJPvjIHDs2fXOvq9ZKaglkNCK2p223siEMmOhN7qPZ+JKVPo0/oOrEQ8y/ovVbFgAAAAEc3NoOg== contact@iampavel.dev"
    ];
  };

  git = {
    username = "Asaduzzaman Pavel";
    email = "contact@iampavel.dev";
  };

  # Hyprland Settings
  extraMonitorSettings = "";

  desktopEnvironment = true;

  # Enable Thunar GUI File Manager
  thunarEnable = false;

  # Default Applications
  defaultApplications = {
    browser = "firefox";
    terminal = "kitty";
  };

  # Keyboard Layout
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # # Set Stylix Image
  # stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  #
  # # Set Waybar
  # # Includes alternates such as waybar-simple.nix & waybar-ddubs.nix
  # waybarChoice = ../../modules/home/waybar/waybar-simple.nix;

  # Set animation style
  ## Available options are:
  ## animations-def.nix  (default)
  ## animations-end4.nix (end-4 project)
  ## animations-dynamic.nix (ml4w project)
  animationStyle = ../../modules/home/hyprland/animations-dynamic.nix;
}
