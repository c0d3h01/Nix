{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    bashrcExtra = ''
      for f in "$HOME/.config/shell/"*.sh; do
        [ -f "$f" ] && source "$f"
      done
    '';
  };
}
