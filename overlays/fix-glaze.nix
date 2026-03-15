self: super: {
  glaze = super.glaze.overrideAttrs (old: {
    # Check if OpenSSL is already in buildInputs and add it if not
    buildInputs = old.buildInputs or [ ] ++ [ self.openssl ];
  });
}
