{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # GUI
    vscode-fhs
    github-desktop
    libreoffice-still
    qbittorrent-enhanced

    # Cli
    distrobox
    nixd
    nil
    gopls
    rust-analyzer
    gcc
    go
    cargo
    rustc
    rustfmt
    python313
    python313Packages.jupyterlab
    ruby
    ocaml
    opam
    texliveBasic
    gspell # spellchecker
    hunspell
    hunspellDicts.en_US
  ];
}
