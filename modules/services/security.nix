{config, ...}: {
  security = {
    polkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = true;
}
