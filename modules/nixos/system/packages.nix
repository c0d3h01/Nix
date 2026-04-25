{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # brave
    # vscode-fhs
    # antigravity-fhs
    # ocaml
    # opam
  ];
}
