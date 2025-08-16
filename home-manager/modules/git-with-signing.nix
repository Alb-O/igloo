{
  pkgs,
  lib,
  globals,
  ...
}: {
  programs.git = {
    enable = true;
    userName = globals.user.name;
    userEmail = globals.user.email;
    extraConfig =
      {
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = false;
        };
        # Enable GitHub CLI credential helper
        "credential \"https://github.com\"" = {
          helper = "${lib.getExe pkgs.gh} auth git-credential";
        };
        "credential \"https://gist.github.com\"" = {
          helper = "${lib.getExe pkgs.gh} auth git-credential";
        };

        # Git signing configuration (if signing key is available in .env)
        # This will only be enabled if the SIGNING_KEY environment variable is set
      }
      // (
        if globals.env ? SIGNING_KEY
        then {
          gpg = {
            format = "ssh";
          };
          "gpg \"ssh\"" = {
            program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          };
          commit = {
            gpgsign = true;
          };
          user = {
            signingKey = globals.env.SIGNING_KEY;
          };
        }
        else {}
      );
  };
}
