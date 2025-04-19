> [!CAUTION]
> These dotfiles are heavily tailored to my needs and will likely not work out
> of the box on your machine. Installing them without inspecting them first is
> likely to almost fully **wipe your computer**.

This is my personal NixOS configuration for my machines. You can find them under
the [hosts](hosts) folder.

You should really not be trying to install them, but you are free to take
inspiration from them. Some small parts are not included and are in a separate
private repository. This includes my secrets (although encrypted with
[sops-nix](https://github.com/Mic92/sops-nix)) and some slightly sensitive data
not worth encrypting.

## Goals

- Declarative Configurations: Define development environment in a clear and structured manner.
- Reproducibility: Guarantee that the same configuration yields identical environments across different machines and operating systems.
- Cross-Platform Support: Ensure compatibility operation on various operating systems.

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
