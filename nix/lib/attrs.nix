{
  self,
  lib,
  ...
}: let
  inherit
    (builtins)
    removeAttrs
    isList
    isAttrs
    mapAttrs
    ;

  mergeAny = lhs: rhs:
    lhs
    // mapAttrs (name: value:
      if isAttrs value
      then lhs.${name} or {} // value
      else if isList value
      then lhs.${name} or [] ++ value
      else value)
    rhs;
in {
  inherit mergeAny;
}
