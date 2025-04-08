{...}: {
  # Authorization
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [
      { command = "/run/current-system/sw/bin/poweroff"; options = [ "NOPASSWD" ]; }
    ];
  }];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
