{ user, ... }: {
  # Codex AI coding assistant configuration
  # Manages XDG compliance and declarative configuration

  home.sessionVariables = {
    # Set codex to use XDG data directory
    CODEX_HOME = "$XDG_DATA_HOME/codex";
  };

  # Declaratively manage codex configuration
  home.file.".local/share/codex/config.toml".text = ''
    # Codex Configuration
    # Full-auto mode settings
    approval_policy = "on-request"
    sandbox_mode = "workspace-write"

    # Trusted projects with full workspace access
    [projects]
    "${user.homeDirectory}" = { trust_level = "trusted" }

    # Allow network access in workspace-write mode
    [sandbox_workspace_write]
    network_access = true
  '';
}
