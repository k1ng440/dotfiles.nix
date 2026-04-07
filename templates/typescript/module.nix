_: {
  perSystem =
    { pkgs, ... }:
    {
      # Development shell with pnpm and TypeScript tools
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs
          pnpm
          nodePackages.typescript
          nodePackages.typescript-language-server
          nodePackages.prettier
        ];

        shellHook = ''
          echo "TypeScript/pnpm dev shell ready"
          echo "Run 'pnpm install' to install dependencies"
        '';
      };
    };
}
