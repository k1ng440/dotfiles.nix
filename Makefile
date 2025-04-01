host != cat /etc/hostname
host ?= rog-beast

repl:
	nix --extra-experimental-features "nix-command flakes repl-flake" --show-trace repl

show:
	nix --extra-experimental-features "nix-command flakes" flake show

fmt:
	nix --extra-experimental-features "nix-command flakes" fmt

update:
	nix --extra-experimental-features "nix-command flakes" flake update

rebuild:
	sudo nixos-rebuild switch --show-trace --flake .#$(host)

installer:
	nix --extra-experimental-features "nix-command flakes" build --show-trace --option eval-cache false .#installers.x86_64-linux.$(host)

hms:
	home-manager switch -b backup --extra-experimental-features "nix-command flakes repl-flake" --show-trace --flake .#$(host)

nixprofiles != ls -dv /nix/var/nix/profiles/system-*-link/|tail -2
homeprofiles != ls -dv ~/.local/state/nix/profiles/home-manager-*-link/|tail -2
show-diff:
	# ======== System diff ======== ";
	nix store diff-closures $(nixprofiles);

	# ======== home-manager diff ======== ";
	nix store diff-closures $(homeprofiles)
