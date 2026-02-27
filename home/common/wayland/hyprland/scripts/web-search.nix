{
  lib,
  pkgs,
  config,
  ...
}:
let
  mod = "SUPER";

  web-search-script = pkgs.writeShellScriptBin "fuzzel-web-search" ''
    # Minimalist Developer Icons (Nerd Font)
    declare -A engines=(
      ["!aws"]="https://docs.aws.amazon.com/search/doc-search.html?searchPath=documentation&searchQuery=|󰅟  AWS Docs"
      ["!cpp"]="https://en.cppreference.com/mwiki/index.php?search=|\t\t  C++ Reference"
      ["!d"]="https://www.deepl.com/translator#ja/en/|\t\t󰗊  DeepL Translate"
      ["!gh"]="https://github.com/search?q=|\t\t  GitHub"
      ["!go"]="https://pkg.go.dev/search?q=|\t\t󰟓  Go Packages"
      ["!jp"]="https://jisho.org/search/|\t\t󰉉  Jisho"
      ["!nix"]="https://search.nixos.org/packages?query=|\t\t  Nix Packages"
      ["!nixopt"]="https://search.nixos.org/options?query=|\t\t󰒓  Nix Options"
      ["!php"]="https://www.php.net/manual-lookup.php?pattern=|\t\t󰌟  PHP Docs"
      ["!py"]="https://docs.python.org/3/search.html?q=|\t\t  Python Docs"
      ["!react"]="https://react.dev/reference/react?q=|\t\t  React Docs"
      ["!rs"]="https://docs.rs/releases/search?query=|\t\t  Rust Crates"
      ["!yt"]="https://www.youtube.com/results?search_query=|\t\t󰗃  YouTube"
    )

    HINTS=""
    for bang in "''${!engines[@]}"; do
      hint=''${engines[$bang]#*|}
      HINTS+="''${bang} ''${hint}\n"
    done

    HINTS=$(echo -e "''${HINTS}" | sort)

    SELECTION=$(echo -e "''${HINTS}" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p "🌐 Search: " --width=60 --lines=12)

    [ -z "''${SELECTION}" ] && exit 0

    PREFIX=$(echo "''${SELECTION}" | cut -d' ' -f1)

    if [[ ''${engines[''${PREFIX}]+_} ]]; then
        # Get URL (part before the |)
        BASE_URL=''${engines[''${PREFIX}]%|*}
        TERM=$(echo "''${SELECTION}" | cut -d' ' -f2-)

        if [ "''${TERM}" = "''${PREFIX}" ] || [ -z "''${TERM}" ]; then
            TERM=$(${pkgs.fuzzel}/bin/fuzzel --dmenu -p "Search ''${PREFIX#*!}: " --lines 0 --width=60)
            [ -z "''${TERM}" ] && exit 0
        fi
    else
        TERM="''${SELECTION}"
        BASE_URL="https://www.google.com/search?q="
    fi

    ENCODED_TERM=$(echo -n "''${TERM}" | ${pkgs.jq}/bin/jq -sRr @uri)
    xdg-open "''${BASE_URL}''${ENCODED_TERM}"
  '';
in
{
  home.packages = [
    web-search-script
    pkgs.jq
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "${mod}, S, exec, ${web-search-script}/bin/fuzzel-web-search"
  ];
}
