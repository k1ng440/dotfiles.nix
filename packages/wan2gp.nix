{
  buildFHSEnv,
  cudaPackages,
  linuxPackages,
  lib,
  fetchFromGitHub,
  writeShellScriptBin,
  ...
}:

let
  wan2gp-src = fetchFromGitHub {
    owner = "deepbeepmeep";
    repo = "Wan2GP";
    rev = "805e110"; # latest commit hash
    hash = "sha256-BiGIxsXFTu4ae9zUJPVBeXfuLwvySTpumVPX3Go5SpA=";
  };

  # A helper script that manages the persistent workspace in the user's home
  wan2gp-launcher = writeShellScriptBin "wan2gp" ''
    WORKSPACE="$HOME/.local/share/wan2gp"
    mkdir -p "$WORKSPACE"
    cd "$WORKSPACE"

    # Sync source if it doesn't exist or is outdated
    if [ ! -f "wgp.py" ]; then
      echo "Setting up Wan2GP in $WORKSPACE..."
      cp -rn ${wan2gp-src}/* .
      chmod -R +w .
    fi

    # Set up virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating Python virtual environment..."
      python -m venv .venv
      source .venv/bin/activate
      echo "Installing dependencies (this may take a few minutes)..."
      pip install --upgrade pip
      # Install torch first for better CUDA compatibility detection
      pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
      pip install -r requirements.txt
    else
      source .venv/bin/activate
    fi

    # Run the app
    echo "Launching Wan2GP..."
    python wgp.py "$@"
  '';

in
buildFHSEnv {
  name = "wan2gp-env";
  targetPkgs =
    pkgs: with pkgs; [
      # System dependencies
      git
      ffmpeg-full
      stdenv.cc.cc.lib
      zlib
      glib
      libx11
      libxcb
      libXext
      libXrender
      libXinerama
      libXcursor
      libXdamage
      libXfixes
      libXi
      libXrandr
      libXcomposite
      libXtst
      libXv
      libXft
      fontconfig
      freetype
      dbus
      atk
      cairo
      gdk-pixbuf
      pango
      gtk3
      libdrm
      mesa
      expat
      libxshmfence
      libxkbcommon
      libglvnd
      libxcrypt-legacy
      bash
      coreutils
      procps
      pkg-config
      libgcc

      # Python environment
      python3
      python3Packages.pip
      python3Packages.virtualenv

      # CUDA support
      cudaPackages.cuda_nvcc
      cudaPackages.cudatoolkit
      linuxPackages.nvidia_x11
    ];

  runScript = "${wan2gp-launcher}/bin/wan2gp";

  profile = ''
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/nvidia-offload/lib:$LD_LIBRARY_PATH"
    export CUDA_PATH=${cudaPackages.cudatoolkit}
    export EXTRA_LDFLAGS="-L/lib -L${linuxPackages.nvidia_x11}/lib"
    export EXTRA_CCFLAGS="-I/usr/include"
    export HF_HOME="$HOME/.cache/huggingface"
  '';

  meta = {
    description = "Self-contained Wan2GP AI Video Generator";
    homepage = "https://github.com/deepbeepmeep/Wan2GP";
    platforms = lib.platforms.linux;
  };
}
