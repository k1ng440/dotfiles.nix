_: {
  # Database for aiding terminal-based programs
  environment.enableAllTerminfo = false;
  # Enable firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
    Defaults env_keep+=SSH_AUTH_SOCK
  '';
}
