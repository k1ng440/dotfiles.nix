{ pkgs, config, ... }:
let
  hpkg = config.wayland.windowManager.hyprland.package;
  hypr-layer-capture = pkgs.writeShellScriptBin "hypr-layer-capture" ''
    export PATH="${
      pkgs.lib.makeBinPath [
        hpkg
        pkgs.diffutils
        pkgs.gnugrep
        pkgs.gnused
        pkgs.coreutils
      ]
    }:$PATH"

    snapshots=()
    last_state=$(hyprctl layers)
    snapshots+=("$last_state")

    echo $last_state
    echo "Monitoring layers... Press any key to stop and show results."

    while ! read -t 0.1 -n 1; do
        current_state=$(hyprctl layers)

        if [[ "$current_state" != "$last_state" ]]; then
            snapshots+=("$current_state")
            last_state="$current_state"
        fi
        sleep 1
    done

    echo -e "\n=== CHANGE LOG ===\n"

    for ((i=0; i<''${#snapshots[@]}-1; i++)); do
        echo "--- Change $((i+1)) -> $((i+2)) ---"

        diff_output=$(diff -U 0 <(echo "''${snapshots[$i]}") <(echo "''${snapshots[$((i+1))]}"))
        diff_output=$(echo "$diff_output" | grep -vE '^(@@|\+\+\+|---)')

        if [[ -z "$diff_output" ]]; then
            echo "No structural changes detected."
        else
            echo "$diff_output" | sed 's/^-/  [REMOVED] /; s/^+/  [ADDED]   /'
        fi
        echo ""
    done
  '';
in
{
  home.packages = [
    hypr-layer-capture
  ];
}
