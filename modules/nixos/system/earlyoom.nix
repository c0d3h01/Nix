{
  # Early OOM system executer to prevent system hangs before systemd-oomd kicks in
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;

    extraArgs = [
      # Prefer execute heavy
      "--prefer"
      "(chrome|firefox|node|electron|code|discord)"

      # Core system daemons
      "--avoid"
      "(sshd|systemd|dbus|NetworkManager)"

      # Shells + editors + terminals (now includes Ghostty)
      "--avoid"
      "(bash|zsh|fish|nvim|vim|alacritty|kitty|wezterm|ghostty)"

      # GNOME session protection
      "--avoid"
      "(gnome-shell|gdm|mutter)"

      # KDE Plasma session protection
      "--avoid"
      "(plasmashell|kwin|ksmserver)"

      # Avoid Brave browser from executing
      "--avoid"
      "(brave|brave-browser)"
    ];
  };
}
