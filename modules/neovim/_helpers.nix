_lib:
let
  mkKeymap = mode: key: action: {
    inherit mode key action;
    silent = true;
  };
in
{
  inherit mkKeymap;

  mkKeymapWithOpts =
    mode: key: action: opts:
    (mkKeymap mode key action) // opts;

  fzf = cmd: "function() require('fzf-lua').${cmd}() end";
}
