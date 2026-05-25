_: {
  perSystem =
    { pkgs, ... }:
    let
      inherit (builtins)
        fromJSON
        readFile
        head
        filter
        ;
      inherit ((fromJSON (readFile "${pkgs.playwright-driver}/browsers.json"))) browsers;
      chromium-rev = (head (filter (x: x.name == "chromium") browsers)).revision;
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          bun
          playwright-driver.browsers
        ];

        shellHook = ''
          export PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH="${pkgs.playwright-driver.browsers}/chromium-${chromium-rev}/chrome-linux64/chrome"
          export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
          export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
        '';
      };
    };
}
