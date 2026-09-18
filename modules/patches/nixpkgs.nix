{
  flake.modules.nixos.core = { pkgs, ... }: {
    nixpkgs-patcher = {
      enable = true;
      settings.patches = with pkgs; [
        (fetchpatch {
          name = "opencode-1.18.30.patch";
          url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/564101.patch";
          hash = "sha256-1/A2yxdJx4qZzPbLx37+QXxeV3nVPQPUk5MMn+EzSrE=";
        })
        (fetchpatch {
          name = "opencode-1.18.31.patch";
          url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/564320.patch";
          hash = "sha256-Z084MG9rXr58DQsn0DhWx0NgwxYHfWQBmOHNyk8eWr0=";
        })
        # playwright-webkit links libmanette since 1.61.1; without it autoPatchelf
        # fails to satisfy libmanette-0.2.so.0. Remove once in the locked nixpkgs.
        (fetchpatch {
          name = "playwright-webkit-libmanette.patch";
          url = "https://github.com/NixOS/nixpkgs/commit/67bf9043b15f21bb8d3379c58c47741b05db922f.patch";
          hash = "sha256-IeuT3lzX212vL30wVl9F7hu9WXKftJqHQpv2OpcOjoI=";
        })
      ];
    };
  };
}
