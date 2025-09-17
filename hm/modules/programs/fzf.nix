# FZF configuration with minimal Tokyo Night theme
{ config, lib, pkgs, dirs, ... }: {
  # Install fzf package
  home.packages = with pkgs; [ fzf ];
  
  # Create fzf configuration as shell script
  home.file."${dirs.localShare}/rc/fzf.sh" = {
    text = ''
      # FZF configuration with minimal Tokyo Night theme
      
      # Minimal Tokyo Night color scheme
      export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border=none
        --info=inline
        --prompt='$ '
        --pointer='>'
        --marker='✶'
        --no-scrollbar
        --no-separator
        --color=bg:#1a1b26,bg+:#292e42,fg:#c0caf5,fg+:#c0caf5:bold
        --color=hl:#7aa2f7,hl+:#7aa2f7:bold,info:#7c7d83,marker:#9ece6a:bold
        --color=prompt:#7aa2f7,spinner:#bb9af7,pointer:#f7768e,header:#73daca
        --color=gutter:#1a1b26
      "
      
      # File search with ripgrep
      export FZF_DEFAULT_COMMAND="rg --files"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      
      # Directory search with fd and eza preview
      export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --icons {} | head -200'"
    '';
    executable = false;
  };
}
