# Purpose: GitHub CLI configuration with SSH auth and workflow aliases
{...}: {
  programs.gh = {
    enable = true;

    settings = {
      editor = "nvim";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # gh extensions managed declaratively
  programs.gh.extensions = [];
}
