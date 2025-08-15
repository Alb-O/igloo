{
  globals,
  ...
}:
{
  # Codex AI coding assistant configuration
  # Manages XDG compliance and declarative configuration

  home.sessionVariables = {
    # Set codex to use XDG data directory
    CODEX_HOME = "$XDG_DATA_HOME/codex";
  };

  # Declaratively manage codex configuration
  home.file.".local/share/codex/config.toml".text =
    let
      # Additional trusted projects from environment variables
      extraProjects =
        if globals.env ? CODEX_TRUSTED_PROJECTS then globals.env.CODEX_TRUSTED_PROJECTS else "";

      projectsConfig =
        if extraProjects != "" then
          ''
            "${globals.user.homeDirectory}" = { trust_level = "trusted" }
            ${extraProjects}
          ''
        else
          ''
            "${globals.user.homeDirectory}" = { trust_level = "trusted" }
          '';
    in
    ''
      # Codex Configuration
      # Trusted projects with full workspace access
      projects = { 
        ${projectsConfig}
      }

      # Full-auto mode settings
      approval_policy = "on-request"
      sandbox_mode = "workspace-write"

      # Allow network access in workspace-write mode
      [sandbox_workspace_write]
      network_access = true
    '';
}
