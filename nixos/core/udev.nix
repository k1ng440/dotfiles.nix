{}: {
  services.udev.extraRules = ''
    # Logitech USB Receiver (Mouse)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c547", TEST=="power/control", ATTR{power/control}="on"
    # Yamaha Steinberg UR22C (Audio)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0499", ATTR{idProduct}=="172f", TEST=="power/control", ATTR{power/control}="on"
  '';
}
