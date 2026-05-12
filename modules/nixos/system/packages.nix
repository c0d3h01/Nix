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
    python312
    jupyter
    ruby
    ocaml
    opam
    texliveBasic
    gspell # spellchecker
    hunspell
    hunspellDicts.en_US
  ];
}
