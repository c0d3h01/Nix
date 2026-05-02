{
  # Network diagnostics plus GnuPG agent SSH support.

  programs.mtr.enable = true;
  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
  };
}
