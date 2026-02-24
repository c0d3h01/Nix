{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withNodeJs = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      tree-sitter
    ];

    # plugins = with pkgs.vimPlugins; [
    # ];

    # initLua = builtins.readFile ./init.lua;
  };
}
