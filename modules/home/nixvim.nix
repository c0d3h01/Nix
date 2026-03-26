{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nixvim.homeModules.nixvim];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    waylandSupport = true;
    colorschemes.gruvbox.enable = true;

    neo-tree = {
      enable = true;
      settings = {
        filesystem.filtered_items.visible = true;
        filesystem.filtered_items.hide_dotfiles = false;
        filesystem.filtered_items.hide_hidden = false;
      };
    };

    plugins = {
      lualine.enable = true;

      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c
          go
          gomod
          gosum
          json
          lua
          markdown
          markdown_inline
          nix
          rust
          sql
          toml
          yaml
        ];
      };

      servers = {
        rust_analyzer.enable = false;

        gopls = {
          enable = true;
          settings = {
            analyses = {
              unusedparams = true;
              shadow = true;
            };
            staticcheck = true;
            gofumpt = true;
          };
        };

        nil_ls = {
          enable = true;
          settings.nix = {
            flake.autoArchive = false;
            maxMemoryMB = 512;
          };
        };

        lua_ls = {
          enable = true;
          settings.Lua = {
            diagnostics.globals = ["vim"];
            workspace.checkThirdParty = false;
          };
        };

        rustaceanvim = {
          enable = true;
          settings.server.settings = {
            cargo.allFeatures = true;
            checkOnSave = true;
            check.command = "clippy";
          };
        };

        nvim-autopairs = {
          enable = true;
          settings.check_ts = true;
        };

        bashls.enable = true;
        taplo.enable = true;
      };
    };
  };
}
