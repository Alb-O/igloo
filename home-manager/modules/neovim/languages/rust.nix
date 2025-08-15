{ pkgs, ... }:
{
  # Rust development environment
  home.packages = with pkgs; [
    # Core Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    # Cargo extensions
    cargo-watch
    cargo-edit
    cargo-generate
    cargo-audit
    cargo-outdated
    cargo-binstall

    # Build dependencies
    gcc
    pkg-config
    openssl
    openssl.dev
  ];

  # Rust-specific environment variables
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
