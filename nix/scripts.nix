{
  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: let
    flash-iso-image = name: image: let
      pv = "${pkgs.pv}/bin/pv";
      fzf = "${pkgs.fzf}/bin/fzf";
    in
      pkgs.writeShellScriptBin name ''
        set -euo pipefail

        # Build image
        nix build .#${image}

        # Display fzf disk selector
        iso="./result/iso/"
        iso="$iso$(ls "$iso" | ${pv})"
        dev="/dev/$(lsblk -d -n --output RM,NAME,FSTYPE,SIZE,LABEL,TYPE,VENDOR,UUID | awk '{ if ($1 == 1) { print } }' | ${fzf} | awk '{print $2}')"

        # Format
        ${pv} -tpreb "$iso" | sudo dd bs=4M of="$dev" iflag=fullblock conv=notrunc,noerror oflag=sync
      '';

    make-iso = name: image: let
      pv = "${pkgs.pv}/bin/pv";
      fzf = "${pkgs.fzf}/bin/fzf";
    in
      pkgs.writeShellScriptBin name ''
        set -euo pipefail

        # Build image
        nix build .#${image}

        # Display fzf disk selector
        iso="./result/iso/"
        iso="$iso$(ls "$iso" | ${pv})"
        echo "Image has been created at $iso"
      '';
  in {
    mission-control.scripts = {
      nix-build-xenomorph = {
        category = "Nix";
        description = "Builds toplevel NixOS image for xenomorph host";
        exec = pkgs.writeShellScriptBin "nix-build-xenomorph" ''
          set -euo pipefail
          nix build .#nixosConfigurations.xenomorph.config.system.build.toplevel
        '';
      };
      nix-build-xenomorph-vm = {
        category = "Nix";
        description = "Builds toplevel NixOS vm for xenomorph host";
        exec = pkgs.writeShellScriptBin "nix-build-xenomorph" ''
          set -euo pipefail
          nix build .#nixosConfigurations.xenomorph.config.system.build.vm
        '';
      };

      make-xenomorph-iso = {
        category = "Images";
        description = "Create installer-iso image for xenomorph";
        exec = make-iso "make-xenomorph-iso" "xenomorph-iso";
      };

      # ISOs
      flash-xenomorph-iso = {
        category = "Images";
        description = "Flash installer-iso image for xenomorph";
        exec = flash-iso-image "flash-xenomorph-iso" "xenomorph-iso";
      };

      # Utils
      fmt = {
        category = "Dev Tools";
        description = "Format the source tree";
        exec = "${lib.getExe config.treefmt.build.wrapper}";
      };

      clean = {
        category = "Utils";
        description = "Cleans any result produced by Nix or associated tools";
        exec =
          pkgs.writeShellScriptBin "clean"
          "rm -rf result* *.qcow2 && echo 'done'";
      };

      run-vm = {
        category = "Utils";
        description = "Executes a VM if output derivation contains one";
        exec = "exec ./result/bin/run-*-vm";
      };

      save-disk-encryption-key = {
        category = "Encryption";
        description = "Decrypt encrypted file using sops and save it to disk";
        exec = ''
          ${pkgs.sops}/bin/sops --decrypt --extract "['$TARGET_HOST']['luks_password']" "$CONFIG_DIR/secrets/secrets.yaml" > /tmp/luks_password'';
      };
    };
  };
}
