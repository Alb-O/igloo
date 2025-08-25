# nixCats-fish user-editable configuration

# XDG defaults
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache

# Fish settings
set -g fish_greeting ""  # Disable greeting
set -g fish_key_bindings fish_vi_key_bindings  # Vi keybindings (change to fish_default_key_bindings for emacs)

# History settings
set -g fish_history_max 50000
set -g fish_history_file $XDG_STATE_HOME/fish/history

# Color scheme - you can customize this
set -g fish_color_normal normal
set -g fish_color_command blue
set -g fish_color_quote yellow
set -g fish_color_redirection cyan
set -g fish_color_end green
set -g fish_color_error brred
set -g fish_color_param normal
set -g fish_color_comment brblack
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_color_history_current --bold
set -g fish_color_operator cyan
set -g fish_color_escape brcyan
set -g fish_color_autosuggestion brblack

# Environment setup
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end

if command -v zoxide >/dev/null 2>&1
    zoxide init fish --cmd cd | source
end

# Aliases - customize as needed
alias ll "eza -la"
alias ls "eza"
alias la "eza -a"
alias lt "eza -T"
alias cat "bat"
alias grep "rg"
alias find "fd"

# Load fzf integration if available
if test -n "$NIXCATS_FZF_PATH"; and test -d "$NIXCATS_FZF_PATH"
    source $__fish_config_dir/conf.d/fzf.fish
end

# Load user customizations from conf.d
set -l config_dir $__fish_config_dir
if set -q FISHCAT_CONFIG_DIR
    set config_dir $FISHCAT_CONFIG_DIR
end

for file in $config_dir/conf.d/*.fish
    test -r "$file"; and source "$file"
end