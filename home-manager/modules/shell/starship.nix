{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 1000;
      scan_timeout = 30;

      # Minimal format - just directory, git, and prompt
      format = "$directory$git_branch$git_status$character";

      character = {
        success_symbol = "[ ->](bold green)";
        error_symbol = "[ ->](bold red)";
      };

      directory = {
        format = "[$path]($style)";
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        format = " [$symbol$branch]($style)";
        style = "bold purple";
        symbol = "";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style)";
        style = "bold red";
        conflicted = " =";
        ahead = " ⇡";
        behind = " ⇣";
        diverged = " ⇕";
        untracked = " ?";
        stashed = " $";
        modified = " !";
        staged = " +";
        renamed = " »";
        deleted = " ✘";
      };
    };
  };
}