_: {
  flake.modules.nixos.shell_playwright =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.playwright-driver.browsers
      ];

      environment.sessionVariables = {
        PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      };
    };
}
