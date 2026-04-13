{
  flake.modules.nixos.core = _: {
    services.envfs = {
      enable = true;
    };
  };
}
