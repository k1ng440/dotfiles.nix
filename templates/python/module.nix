{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      drv =
        {
          python3Packages,
          installShellFiles,
        }:
        python3Packages.buildPythonApplication {
          pname = "my-python-app";
          version = "0.1.0";

          src = ./.;

          # Dependencies from pyproject.toml or requirements.txt
          propagatedBuildInputs = with python3Packages; [
            # Add runtime dependencies here
          ];

          # Build dependencies
          nativeBuildInputs = [
            installShellFiles
          ];

          # Optional: generate shell completions if your CLI supports it
          # postInstall = ''
          #   installShellCompletion --cmd my-python-app \
          #     --bash <($out/bin/my-python-app --bash-completion) \
          #     --fish <($out/bin/my-python-app --fish-completion) \
          #     --zsh <($out/bin/my-python-app --zsh-completion)
          # '';

          meta = {
            description = "My Python application";
            license = lib.licenses.mit;
            mainProgram = "my-python-app";
          };
        };
    in
    {
      packages.my-python-app = pkgs.callPackage drv { };

      # Development shell with Python tools
      devShells.default = pkgs.mkShell {
        packages = with pkgs.python3Packages; [
          python
          pip
          venvShellHook
          black
          ruff
          mypy
          pytest
        ];
        venvDir = ".venv";
        postVenvCreation = ''
          pip install -e .
        '';
      };
    };

  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.custom.my-python-app ];
    };
}
