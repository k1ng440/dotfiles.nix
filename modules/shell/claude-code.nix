_: {
  flake.modules.nixos.shell_claude-code =
    { pkgs, lib, ... }:
    let
      mcpConfigFile = pkgs.writeText "playwright-mcp-config.json" (
        builtins.toJSON {
          mcpServers = {
            playwright = {
              command = "/run/current-system/sw/bin/playwright-mcp";
              type = "stdio";
              env = {
                PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
                PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
              };
            };
          };
        }
      );
    in
    {
      environment.systemPackages = [
        pkgs.claude-code
        pkgs.playwright-mcp
      ];

      systemd.user.services.claude-mcp-playwright = {
        description = "Configure Playwright MCP for Claude Code";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Environment = [
            "PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}"
            "PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true"
          ];
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "claude-mcp-playwright-setup";
              runtimeInputs = [ pkgs.jq ];
              text = ''
                CLAUDE_JSON="$HOME/.claude.json"

                if [ -f "$CLAUDE_JSON" ]; then
                  MERGED=$(jq --slurpfile mcp "${mcpConfigFile}" \
                    '.mcpServers = (.mcpServers // {} | . + $mcp[0].mcpServers)' \
                    "$CLAUDE_JSON")
                  printf '%s' "$MERGED" > "$CLAUDE_JSON"
                else
                  cp "${mcpConfigFile}" "$CLAUDE_JSON"
                fi
              '';
            }
          );
        };
      };

      custom.persist = {
        home.directories = [
          ".claude"
        ];
      };
    };
}
