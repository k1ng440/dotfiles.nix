{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf # Fuzzy finder for terminal
    wl-clipboard # Wayland clipboard utility
    trash-cli # Command-line trash can management
    ripgrep # Fast text search tool
    jq # JSON processor for terminal
    bottom # System monitor with interactive UI
    bat # Syntax-highlighting file viewer
    nh # Nix helper tool
    bmon # Modern Unix `iftop`
    chafa # Terminal image viewer
    cpufetch # Terminal CPU info
    croc # Terminal file transfer
    curlie # Terminal HTTP client
    cyme # Modern Unix `lsusb`
    dconf2nix # Nix code from Dconf files
    dogdns # Modern Unix `dig`
    fastfetch # Modern Unix system info
    fd # Modern Unix `find`
    file # Terminal file info
    frogmouth # Terminal markdown viewer
    girouette # Modern Unix weather
    hr # Terminal horizontal rule
    hyperfine # Terminal benchmarking
    iperf3 # Terminal network benchmarking
    ipfetch # Terminal IP info
    mtr # Modern Unix `traceroute`
    nixpkgs-review # Nix code review
    nix-prefetch-scripts # Nix code fetcher
    optipng # Terminal PNG optimizer
    rclone # Modern Unix `rsync`
    rsync # Traditional `rsync`
    tldr # Modern Unix `man`
    speedtest-go # Terminal speedtest.net
    upterm # Terminal sharing
    speedtest-go # Terminal speedtest.net
    timer # Terminal timer
    usbutils # Terminal USB info
    gocryptfs # Encryption

    age   # modern and secure file encryption tool
    sops  # Simple and flexible tool for managing secrets
    ssh-to-age # Convert SSH Ed25519 keys to age keys
  ];
}
