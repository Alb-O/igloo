{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
          ufetch
      end
      function fish_prompt
        set_color purple
        date "+%a %b %d %I:%M:%S %p"
        set_color green
        echo (prompt_pwd) (set_color normal)'-> '
      end
      function fish_right_prompt
        set_color blue
        fish_git_prompt
      end

      direnv hook fish | source
    '';
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
