{
  description = "k1ng's NixOS Configuration";

  outputs =
    inputs@{ flake-parts, ... }:
    let
      inherit (inputs.nixpkgs.lib.fileset) toList fileFilter;
      import-tree =
        path:
        toList (fileFilter (file: file.hasExt "nix" && !(inputs.nixpkgs.lib.hasPrefix "_" file.name)) path);
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = import-tree ./modules;

      flake.templates = import ./templates;
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    flake-parts.url = "github:hercules-ci/flake-parts";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hjem.follows = "hjem";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Security and secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland window manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Noctalia v5 desktop shell (https://docs.noctalia.dev).
    #
    # Upstream renamed `noctalia-shell` -> `noctalia` when v5 landed, so the old
    # URL still resolved -- but only to whatever commit flake.lock pinned, which
    # was still v4. Any `nix flake update` would have silently pulled v5 under a
    # v4-shaped config and broken it.
    #
    # Tracked on the `cachix` branch, which always points at the newest commit
    # that CI has already built, so updates can't land on an uncached commit.
    #
    # Deliberately does NOT set inputs.nixpkgs.follows: Noctalia builds its
    # package against its own nixpkgs input, and overriding that input changes
    # the derivation hash and forces a local build. noctalia.cachix.org is
    # already wired up in modules/shell/nix/settings.nix.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    systems.url = "github:nix-systems/default";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal Repositories
    nix-secrets = {
      url = "git+ssh://git@gitlab.com/k1ng4401/nix-secrets.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pi coding agent
    pi.url = "github:lukasl-dev/pi.nix";

    # opencode 1.x, nix package lives in the opencode repo itself.
    #
    # Pinned to 1.x on purpose: 2.x changed the plugin contract. A plugin's
    # default export must now be `{ id, setup }`, whereas the ponytail plugin
    # (and every 1.x-era plugin) exports a bare async setup function, so 2.x
    # rejects it with PluginModule.LoadError. 2.x also dropped the
    # `experimental.chat.system.transform` hook ponytail uses to inject its
    # ruleset every turn, so the plugin has no equivalent on 2.x. On top of
    # that, 2.x's Host.resolve probes `<pkg>/server` before the bare specifier;
    # ponytail's exports map has no "./server" key and the failure is rethrown
    # rather than falling back. Bump this only once ponytail ships 2.x support.
    #
    # Deliberately does not follow our nixpkgs: it builds with a pinned bun,
    # and the node_modules fixed-output hash only matches with that bun.
    opencode.url = "github:anomalyco/opencode/v1.18.34";

    # hermes agent (Nous Research), CLI + Electron desktop app.
    #
    # Upstream ships the Nix packaging itself: a flake with a Home Manager
    # module, plus nix/desktop.nix, which patches the Electron binary and
    # compiles node-pty against Electron's headers. Nothing is in nixpkgs.
    #
    # No binary cache has the package (their hermes-agent.cachix.org holds no
    # narinfo for it), so the first build compiles the whole uv2nix venv
    # locally. Slow once, then incremental.
    hermes = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hex voice dictation (https://anoma.ly/hex/).
    #
    # Builds from source; no binary cache, so the first switch compiles it.
    # Its nixpkgs must follow ours so the Vulkan drivers the system provides
    # match the glibc Hex was built against.
    hex = {
      url = "github:anomalyco/hex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
