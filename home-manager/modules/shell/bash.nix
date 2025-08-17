{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./starship.nix
    ./direnv.nix
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];

    initExtra = ''
      # Initialize starship
      eval "$(starship init bash)"

      # Initialize direnv
      eval "$(direnv hook bash)"

      # Load ble.sh
      source ${pkgs.unstable.blesh}/share/blesh/ble.sh
    '';
  };

  home.packages = with pkgs.unstable; [
    blesh
  ];
}
