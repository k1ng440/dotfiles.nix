# dotfiles.nix
This project is dedicated to crafting and maintaining development environments that are declarative, reproducible, and cross-platform. By leveraging the power of Nix

## Goals
- Declarative Configurations: Define development environment in a clear and structured manner.
- Reproducibility: Guarantee that the same configuration yields identical environments across different machines and operating systems.
- Cross-Platform Support: Ensure compatibility operation on various operating systems.

📂 Repository Structure
```
.
├── home
├── hosts
│  └── <host>
│     ├── hardware-configuration.nix
│     ├── home.nix
│     └── os.nix
├── modules
│  ├── configs
│  ├── services
│  ├── core-desktop.nix
│  └── core-server.nix
├── lib
├── Makefile
└── flake.nix
```

## Get started
1. Clone the Repository:
```bash
    git clone https://github.com/k1ng440/dotfiles.nix.git ~/nix-config
    cd ~/nix-config
```

2. Install Nix: If you haven't already, install the Nix package manager by following the instructions at https://nixos.org/download.html.

3. Set Up the Environment:
    - For NixOS Systems:
    ```bash
        make rebuild
    ```

    - For Non-NixOS Systems: Utilize Home Manager to manage user environments
    ```bash
        make hms
    ```


## 🔧 Customization
Feel free to tailor the configurations to suit your personal preferences and project requirements. The declarative nature of Nix makes it straightforward to adjust packages, settings, and environments. For guidance on customizing Nix configurations, refer to the [NixOS Wiki](https://nixos.wiki/).

## TODOs
All TODOs, known issues, etc, are tracked in the [issues](https://github.com/k1ng440/dotfiles.nix/issues)

## 🤝 Contributing
Contributions are welcome! If you have suggestions, improvements, or encounter issues, please open an issue or submit a pull request. Collaborative efforts help make dotfiles.nix more robust and versatile.

## Reference 
- [NixOS Wiki](https://nixos.wiki/).
- Inspiration from the exemplary work [albe2669/dotfiles](https://github.com/albe2669/dotfiles)



