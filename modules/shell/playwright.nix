_: {
  flake.modules.nixos.shell_playwright =
    { pkgs, ... }:
    let
      inherit (builtins.fromJSON (builtins.readFile "${pkgs.playwright-driver}/browsers.json")) browsers;
      chromium-rev = (builtins.head (builtins.filter (x: x.name == "chromium") browsers)).revision;
      chromium-bin = "${pkgs.playwright-driver.browsers}/chromium-${chromium-rev}/chrome-linux64/chrome";

      playwright-mcp-wrapper = pkgs.writeShellScriptBin "playwright-mcp-wrapper" ''
        exec ${pkgs.playwright-mcp}/bin/playwright-mcp \
          --headless \
          --no-sandbox \
          --isolated \
          --executable-path=${chromium-bin} \
          "$@"
      '';
    in
    {
      environment.systemPackages = [
        pkgs.playwright-driver.browsers
        pkgs.playwright-mcp
        playwright-mcp-wrapper
      ];

      environment.sessionVariables = {
        PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      };
    };
}
