{
  programs.gh = {
    enable = true;

    settings = {
      editor = "nvim";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.gh.extensions = [];
}
