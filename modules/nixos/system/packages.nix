{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # [*] Graphical applications
    brave
    vscode-fhs
    antigravity-fhs
    github-desktop
    libreoffice
    qbittorrent-enhanced

    # [*] cli tools

    # language server protocol
    nixd
    nil
    gopls
    rust-analyzer

    # language
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

    # [*] SpellChecker packages
    gspell # gtk spellchecker
    hunspell
    hunspellDicts.en_US
    hunspellDicts.hi_IN   # Hindi
    hunspellDicts.mr_IN   # Marathi
  ];
}
