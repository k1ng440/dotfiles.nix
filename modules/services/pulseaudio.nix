{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pulseaudio
    pavucontrol
  ];

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  services.pipewire.enable = false;

  nixpkgs.config.pulseaudio = true;

  users.users.${username}.extraGroups = ["audio"];
}
