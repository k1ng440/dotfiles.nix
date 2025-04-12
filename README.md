# dotfiles.nix

This project is dedicated to crafting and maintaining development environments that are declarative, reproducible, and cross-platform. By leveraging the power of Nix

## Goals

- Declarative Configurations: Define development environment in a clear and structured manner.
- Reproducibility: Guarantee that the same configuration yields identical environments across different machines and operating systems.
- Cross-Platform Support: Ensure compatibility operation on various operating systems.

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


## 🤝 Contributing

Contributions are welcome! If you have suggestions, improvements, or encounter issues, please open an issue or submit a pull request. Collaborative efforts help make dotfiles.nix more robust and versatile.

## Reference

- [NixOS Wiki](https://nixos.wiki/wiki/Main_Page).
- [Manual](https://nixos.org/manual/nixos/stable/index.html)

- Videos / Tutorials:

  - [Nixos and Hyprland - Best Match Ever](https://www.youtube.com/watch?v=61wGzIv12Ds)
  - [Flake-parts: writing custom flake modules](https://www.vtimofeenko.com/posts/flake-parts-writing-custom-flake-modules/)
  - [Ultimate Nix Flakes Guide - Vimjoyer](https://www.youtube.com/watch?v=JCeYq72Sko0)
  - [Customize Nix Packages | Gentoo Experience on NixOS - Vimjoyer](https://www.youtube.com/watch?v=jHb7Pe7x1ZY)
  - [Nix Hour](https://www.youtube.com/results?search_query=nix+hour)
  - [Linux Gaming Setup - Vimjoyer](https://www.youtube.com/watch?v=qlfm3MEbqYA)
  - [Stylix - Vimjoyer](https://www.youtube.com/watch?v=ljHkWgBaQWU)

- articles:
  - [Nix by example](https://medium.com/@MrJamesFisher/nix-by-example-a0063a1a4c55)
  - [Secret Management](https://unmovedcentre.com/posts/secrets-management)

- Inspired by other's configurations:
  - [Zaney](https://gitlab.com/Zaney/zaneyos)
  - [Andrew Kvalheim](https://codeberg.org/AndrewKvalheim/configuration)
  - [berbieche](https://github.com/berbiche/dotfiles)
  - [EmergentMind](https://github.com/EmergentMind/nix-config)

## Search:

- [noogle](https://noogle.dev)
- [NixOS Search Options](https://search.nixos.org/options)
- [NixOS Search Packages](https://search.nixos.org/packages)
- [home-manager specific config options](https://mipmip.github.io/home-manager-option-search/)
- [home-manager specific config search](https://home-manager-options.extranix.com/)

## example nix repl

- nixpkgs.lib

```nix
$ nix repl
Welcome to Nix version 2.3.2. Type :? for help.

nix-repl> :l <nixpkgs>
Added 11364 variables.

nix-repl> lib.platforms.i686
[ "i686-cygwin" "i686-freebsd" "i686-linux" "i686-netbsd" "i686-openbsd" "i686-darwin" "i686-windows" "i686-none" ]
```

- [flake-parts debugging](https://flake.parts/options/flake-parts.html)

```
$ nix repl
nix-repl> :lf .
nix-repl> currentSystem._module.args.pkgs.hello
```

## Commands

- List all packages in system path

```bash
nix eval --json .#nixosConfigurations.xenomorph.config.environment.systemPackages --apply 'builtins.map (p: p.name)' | jq . | less
```
