{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      drv =
        {
          buildGoModule,
          installShellFiles,
        }:
        buildGoModule {
          pname = "my-go-app";
          version = "0.1.0";

          src = ./.;

          # Required: set proxyVendor = true and update vendorHash after first failed build
          proxyVendor = true;
          vendorHash = lib.fakeHash; # Build once, then replace with actual hash

          nativeBuildInputs = [ installShellFiles ];

          # Optional: generate shell completions if your app supports it
          postInstall = ''
            installShellCompletion --cmd my-go-app \
              --bash <($out/bin/my-go-app completion bash) \
              --fish <($out/bin/my-go-app completion fish) \
              --zsh <($out/bin/my-go-app completion zsh)
          '';

          meta = {
            description = "My Go application";
            license = lib.licenses.mit;
          };
        };
    in
    {
      packages.my-go-app = pkgs.callPackage drv { };
    };

  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.custom.my-go-app ];
    };
}
