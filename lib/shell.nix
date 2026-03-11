# dev shell for working on this repo
{
  pkgs,
  formatter,
}:
pkgs.mkShell {
  name = "nix-dotfiles";

  nativeBuildInputs = with pkgs; [
    gnumake
    gitMinimal
    nil
    age
    (git-crypt.override {git = gitMinimal;})
    sops
    formatter
    nix-output-monitor
    home-manager
  ];
}
