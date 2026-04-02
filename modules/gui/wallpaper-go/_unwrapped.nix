{
  lib,
  buildGoModule,
  installShellFiles,
}:
buildGoModule {
  pname = "wallpaper-go-unwrapped";
  version = "0.1.0";

  src = ./.;

  proxyVendor = true;
  vendorHash = "sha256-CKQWNSlkpK1HNbcL47j3iVMo1dqyVy2VZidB3rYWLjo=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = ''
    mv $out/bin/wallpaper-go $out/bin/wallpaper

    installShellCompletion --cmd wallpaper \
      --bash <($out/bin/wallpaper generate bash) \
      --fish <($out/bin/wallpaper generate fish) \
      --zsh <($out/bin/wallpaper generate zsh)
  '';

  meta = {
    description = "Wallpaper management utility";
    license = lib.licenses.mit;
  };
}
