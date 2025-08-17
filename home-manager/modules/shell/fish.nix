{
  imports = [ ./starship.nix ./direnv.nix ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
          ufetch
      end

      # Initialize starship
      starship init fish | source

      direnv hook fish | source
    '';
  };

}