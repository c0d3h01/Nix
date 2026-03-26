{
  programs.lazygit = {
    enable = true;

    settings = {
      confirmOnQuit = false;

      git = {
        autoFetch = false;
        merging = {
          args = "";
          manualCommit = false;
        };
        pagers = [
          {
            colorArg = "always";
            useConfig = true;
          }
        ];
      };

      gui = {
        commitLength.show = true;
        mouseEvents = true;
        scrollHeight = 2;
        scrollPastBottom = true;
        sidePanelWidth = 0.3;
        theme = {
          activeBorderColor = [
            "cyan"
            "bold"
          ];
          inactiveBorderColor = ["green"];
          lightTheme = true;
          optionsTextColor = ["blue"];
          selectedLineBgColor = ["reverse"];
          selectedRangeBgColor = ["blue"];
        };
      };
    };
  };
}
