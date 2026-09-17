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
      ];
    };
  };
}
