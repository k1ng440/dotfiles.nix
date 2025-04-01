{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
  ];

  environment.variables.EDITOR = "nvim";
}
