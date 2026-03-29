{pkgs, ...}: {
  # Go Development Environment
  # Provides Go toolchain, gopls LSP, and essential Go tools

  home.packages = with pkgs; [
    # Go language
    go_1_23

    # Go Language Server Protocol (LSP) for editor integration
    gopls

    # Essential Go development tools
    delve # Debugger
    gotools # Collection of Go tools (gofmt, goimports, etc.)
    go-tools # Additional Go analysis tools

    # Build and dependency management
    gomodifytags # Modify struct tags
    impl # Generate interface implementations
    go-outline # Go symbol outline

    # Testing and benchmarking
    gotestsum # Improved test output
    gocov # Test coverage tool
    gocov-shield # Coverage badge generator
  ];

  # Go environment variables
  home.sessionVariables = {
    GOPRIVATE = "github.com/c0d3h01";
    GO111MODULE = "on";
  };
}
