{ pkgs }:
pkgs.writeShellScriptBin "replace-string" ''
  if [ "$#" -lt 2 ]; then
    echo "Usage: replace-string <search_string> <replace_string> [directory]"
    echo "Example: replace-string \"old-string\" \"new-string\" ."
    exit 1
  fi

  SEARCH=$1
  REPLACE=$2
  DIR=''${3:-.}

  # Use ripgrep to find files containing the exact string (-lF)
  # and pipe them to sd to perform the exact string replacement (-s).
  ${pkgs.ripgrep}/bin/rg -lF "$SEARCH" "$DIR" | ${pkgs.findutils}/bin/xargs -r ${pkgs.sd}/bin/sd -s "$SEARCH" "$REPLACE"

  echo "Replaced '$SEARCH' with '$REPLACE' in $DIR"
''
