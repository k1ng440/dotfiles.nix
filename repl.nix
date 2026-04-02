# Better repl with preloaded functions and libs already loaded
# https://bmcgee.ie/posts/2023/01/nix-and-its-slow-feedback-loop/#how-you-should-use-the-repl
{
  # host is passed down from the repl via a --arg argument, defaulting to the current host
  host ? "xenomorph",
  ...
}:
let
  user = "k1ng";
  flake = builtins.getFlake (toString ./.);
  inherit (flake.inputs.nixpkgs) lib;
  help = ''

    --- Nix REPL へようこそ (Welcome)  ---
    - keys <set>        : List attribute names of a set
    - where "opt.path"  : Find the files defining an option (filtered for your flake)
    - deps <pkg>        : List build inputs for a package
    - reload            : Re-import this repl.nix file
    - c / config        : Current host's config (${host})
    - co                : Current host's custom options (c.custom)
    - pkgs              : Nixpkgs for the current host
    --------------------------------------
  '';
in
builtins.trace help (
  flake.nixosConfigurations
  |> lib.attrNames
  |> lib.filter (n: !(lib.hasInfix "-" n))
  |> map (
    name:
    let
      cfg = flake.nixosConfigurations.${name}.config;
    in
    {
      "${name}" = cfg;
      "${name}o" = cfg.custom;
    }
  )
  |> lib.mergeAttrsList
)
// rec {
  inherit lib;
  inherit (flake) inputs;
  inherit
    flake
    host
    user
    help
    ;
  self = flake;

  # default host
  inherit (flake.nixosConfigurations.${host}) pkgs;
  c = flake.nixosConfigurations.${host}.config;
  config = c;
  options = flake.nixosConfigurations.${host}.options;
  co = c.custom;
  reload = import ./repl.nix { inherit host; };
  keys = lib.attrNames;
  deps = pkg: builtins.map (p: p.name or "unknown") (pkg.buildInputs ++ pkg.nativeBuildInputs or [ ]);
  where =
    path:
    let
      opt = lib.attrByPath (lib.splitString "." path) null options;
      decls =
        if opt != null && opt ? files then
          opt.files
        else
          (lib.attrByPath (lib.splitString "." path) { _files = [ ]; } options)._files or [ ];
      isMine = f: !(lib.hasInfix "nixos/modules/" (toString f));
      myFiles = lib.filter isMine decls;
    in
    if myFiles == [ ] then decls else myFiles;
}
