.SILENT: show-diff clean-cows

host ?= $(cat /etc/hostname 2>/dev/null || echo xenomorph)

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

hms:
	home-manager switch -b backup --extra-experimental-features "nix-command flakes repl-flake" --show-trace --flake .#$(host)

run-vm:
	nix build .#nixosConfigurations.${host}.config.system.build.vm
	./result/bin/run-${host}-vm

build-iso:
	nix build .#nixosConfigurations.isoimage.config.system.build.isoImage

clean-cows:
	p=$(readlink result)
	rm result
	for i in $(nix-store --query --requisites $p); do
	nix-store --delete $i
	done

diff:
	if ls /nix/var/nix/profiles/system-*-link >/dev/null 2>&1; then \
	echo "======== System diff ========"; \
	nix store diff-closures $$(ls -dv /nix/var/nix/profiles/system-*-link | tail -2); \
	else \
	echo "No system profiles found"; \
	fi
	if ls ~/.local/state/nix/profiles/home-manager-*-link >/dev/null 2>&1; then \
	echo "======== home-manager diff ========"; \
	nix store diff-closures $$(ls -dv ~/.local/state/nix/profiles/home-manager-*-link | tail -2); \
	else \
	echo "No home-manager profiles found"; \
	fi
