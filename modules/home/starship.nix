_: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      # Pure prompt inspired — clean, minimal, elegant
      format = ''
        $directory$git_branch$git_status$git_state$cmd_duration
        $character
      '';

      right_format = "$nix_shell$python$nodejs$rust$golang$java$c";

      add_newline = true;

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      directory = {
        style = "blue";
        truncation_length = 4;
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "";
        style = "242"; # muted gray
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "cyan";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "≡";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      git_state = {
        format = "[$state( $progress_current/$progress_total)]($style) ";
        style = "yellow";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
        min_time = 2000; # show only if > 2s
      };

      # --- Language/tool context (right side, shown only when relevant) ---

      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style) ";
        symbol = " ";
        style = "bold blue";
      };

      python = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "yellow";
      };

      nodejs = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "green";
      };

      rust = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "red";
      };

      golang = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "cyan";
      };

      java = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "red";
      };

      c = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "149"; # muted green
      };

      # --- Disabled modules (keep it clean) ---
      package.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
      azure.disabled = true;
    };
  };
}
