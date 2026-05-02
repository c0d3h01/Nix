{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # GUI
    # brave
    google-chrome
    vscode-fhs
    antigravity-fhs
    github-desktop
    libreoffice
    qbittorrent-enhanced

    # Cli
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
