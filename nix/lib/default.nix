{lib, ...} @ args: let
  mkLib = self: let
    importLib = file: import file ({inherit self;} // args);
  in {
    attrs = importLib ./attrs.nix;
    importers = importLib ./importers.nix;
    options = importLib ./options.nix;

    inherit (self.attrs) mergeAny;
    inherit (self.importers) rakeLeaves flattenTree getInputsByPrefix;
    inherit (self.options) mkEnableOpt' mkOpt mkOptStr mkBoolOpt;
  };
in
  lib.makeExtensible mkLib
