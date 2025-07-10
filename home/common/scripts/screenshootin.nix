{ pkgs }:
pkgs.writeShellScriptBin "screenshootin" ''
  output_dir="$HOME/Pictures/Screenshots"
  hyprshot --freeze -m region -o $output_dir
  latest_screenshot=$(ls -t $output_dir/*.png | head -n 1)
  swappy -f "$latest_screenshot"
''
