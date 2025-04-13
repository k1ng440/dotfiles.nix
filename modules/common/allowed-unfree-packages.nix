{lib, ...}: {
  nixpkgs-unstable.config = {
    allowUnfree = true;
  };
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "obsidian"
      "postman"
      "vscode"
      "vscode-extension-github-copilot"
      "slack"
      "zoom"
      "discord"
      "spotify"
      "cuda_cudart"
    ];
}
