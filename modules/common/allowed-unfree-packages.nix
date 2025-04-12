{lib, ...}: {
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
    ];
}
