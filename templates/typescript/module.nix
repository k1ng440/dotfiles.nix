_: {
  perSystem =
    { pkgs, ... }:
    {
      # Development shell with pnpm and TypeScript tools
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          typescript
          nodejs
          pnpm
          typescript-language-server
          prettier
        ];

        shellHook = ''
          echo "TypeScript/pnpm dev shell ready"
          echo "Run 'pnpm install' to install dependencies"
        '';
      };
    };
}
