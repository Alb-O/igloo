{
  pkgs,
  lib,
  globals,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = globals.user.name;
    userEmail = globals.user.email;

    extraConfig = {
      # Basic Git configuration without signing
      init.defaultBranch = "main";
      pull.rebase = false;

      # Enable GitHub CLI credential helper
      credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
    };
  };
}
