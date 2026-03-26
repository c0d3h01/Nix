{
  programs.lsd = {
    enable = false;

    settings = {
      color = {
        when = "always";
        theme = "default";
      };
      size = "short";
      "total-size" = false;
      indicators = false;
      "no-symlink" = false;
      layout = "grid";
      hyperlink = "auto";
      icons = {
        when = "never";
        theme = "fancy";
        separator = "  ";
      };
      date = "relative";
      permission = "rwx";
      sorting = {
        column = "name";
        reverse = false;
        "dir-grouping" = "first";
      };
      blocks = [
        "permission"
        "size"
        "date"
        "git"
        "name"
      ];
      "symlink-arrow" = "->";
    };
  };
}
