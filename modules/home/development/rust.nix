{pkgs, ...}: {
  # Rust Development Environment
  # Provides Rust toolchain via rustup, rust-analyzer LSP, and essential tools

  home.packages = with pkgs; [
    # Rust toolchain manager (installs rustc, cargo, rustfmt, clippy, etc.)
    rustup

    # Essential Rust development tools
    rust-analyzer # Language Server Protocol for Rust
    cargo-audit # Audit Cargo.lock for security vulnerabilities
    cargo-edit # Extend Cargo with subcommands (add, rm, upgrade)
    cargo-watch # Watch for file changes and run commands
    cargo-nextest # Modern test runner for Rust
    cargo-flamegraph # Generate flamegraphs for profiling
    cargo-tarpaulin # Code coverage tool
    cargo-expand # Expand macros in Rust code
    cargo-outdated # Check for outdated dependencies
    cargo-udeps # Find unused dependencies
    cargo-binstall # Fast binary installation for cargo packages

    # Additional utilities
    bindgen # Generate Rust bindings from C headers
    cbindgen # Generate C bindings from Rust code
  ];

  # Rust environment configuration
  home.sessionVariables = {
    RUST_BACKTRACE = "1";
    CARGO_TERM_COLOR = "always";
    CARGO_INCREMENTAL = "0"; # Disable incremental compilation to save disk space
  };

  # Configure rustup default toolchain
  xdg.configFile."rustup/settings.toml".text = ''
    default_toolchain = "stable"
    profile = "default"
  '';
}
