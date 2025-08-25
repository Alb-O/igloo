# nixCats-fish main configuration
# This file is loaded after nixCats integration (000-nixcats.fish)

# XDG environment setup
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache

# Fish configuration  
set -g fish_greeting ""  # Disable default greeting

# Key bindings: Use vi mode by default for power users
set -g fish_key_bindings fish_vi_key_bindings

# Enable useful fish features
set -g fish_autocd true  # cd by just typing directory name
set -g fish_vi_force_cursor true  # Better vi cursor support

# History configuration - generous settings for productivity
set -g fish_history_max 100000
set -g fish_history_file $XDG_STATE_HOME/fish/fish_history
set -g fish_save_history_on_exit true

# Color scheme based on theme from nixCats extra config
if functions -q fishCats
    set -l theme_name (fishCats --get theme)
else
    set -l theme_name "default"
end

switch $theme_name
    case "tokyonight-night"
        # Tokyo Night theme colors
        set -g fish_color_normal normal
        set -g fish_color_command 7aa2f7
        set -g fish_color_quote 9ece6a
        set -g fish_color_redirection 7dcfff
        set -g fish_color_end bb9af7
        set -g fish_color_error f7768e
        set -g fish_color_param c0caf5
        set -g fish_color_comment 565f89
        set -g fish_color_selection white --bold --background=brblack
        
    case "catppuccin-mocha"
        # Catppuccin Mocha theme colors
        set -g fish_color_normal cdd6f4
        set -g fish_color_command 89b4fa
        set -g fish_color_quote a6e3a1
        set -g fish_color_redirection f5c2e7
        set -g fish_color_end fab387
        set -g fish_color_error f38ba8
        set -g fish_color_param f2cdcd
        set -g fish_color_comment 6c7086
        
    case '*'
        # Default Fish colors (keep current)
        # Fish will use its built-in defaults
end

# Environment variable setup
if functions -q fishCats
    set -l editor_cmd (fishCats --get editor)
    if test -n "$editor_cmd" -a "$editor_cmd" != "null"
        set -gx EDITOR $editor_cmd
    end
end

# Load category-based configuration only if fishCats is available
if functions -q fishCats
    # Modern CLI aliases - only if modern category is enabled
    if fishCats modern.core
        alias ls eza
        alias ll "eza -la"
        alias la "eza -a" 
        alias lt "eza -T"
        alias cat bat
        alias grep rg
        alias find fd
    end

    if fishCats modern.extended
        alias du dust
        alias ps procs
        alias top btm
    end

    # Development aliases - only if development category is enabled
    if fishCats development
        alias gs "git status"
        alias ga "git add"
        alias gc "git commit"
        alias gp "git push"
        alias gd "git diff"
        alias gl "git log --oneline"
    end

    # Environment management
    if fishCats development; and command -v direnv >/dev/null 2>&1
        direnv hook fish | source
    end

    # Smart directory navigation  
    if fishCats navigation; and command -v zoxide >/dev/null 2>&1
        zoxide init fish --cmd cd | source
    end

    # Load category-specific configuration modules
    # Map modules to their actual categories (some modules load under different categories)
    set -l module_mappings \
        "fzf:fzf" \
        "git:development" \
        "navigation:navigation" \
        "development:development" \
        "utilities:utilities" \
        "keybindings:general"
    
    for mapping in $module_mappings
        set -l module (string split ":" $mapping)[1]
        set -l category (string split ":" $mapping)[2]
        
        if fishCats $category
            set -l config_file $__fish_config_dir/conf.d/$module.fish
            if test -r $config_file
                source $config_file
            end
        end
    end
else
    # Fallback configuration when fishCats is not available
    if command -v eza >/dev/null 2>&1
        alias ls eza
        alias ll "eza -la"
    end
    if command -v bat >/dev/null 2>&1  
        alias cat bat
    end
    if command -v rg >/dev/null 2>&1
        alias grep rg
    end
    if command -v fd >/dev/null 2>&1
        alias find fd
    end
    
    # Load all conf.d modules unconditionally as fallback
    for config_file in $__fish_config_dir/conf.d/*.fish
        if test -r $config_file
            source $config_file
        end
    end
end

# Welcome message showing enabled categories
if status is-interactive
    if test "$fish_greeting" = ""
        if functions -q fishCats
            set -l package_name (fishCats --get packageName)
            if test -n "$package_name" -a "$package_name" != "null"
                echo "🐱 "(set_color --bold)"nixCats-fish"(set_color normal)" ready! Package: "$package_name
            else
                echo "🐱 "(set_color --bold)"nixCats-fish"(set_color normal)" ready!"
            end
            
            # Show enabled categories
            set -l enabled_cats (fishCats --list | string join ", ")
            if test -n "$enabled_cats"
                echo "📦 Active categories: "(set_color blue)$enabled_cats(set_color normal)
            end
            
            # Show theme if set
            set -l theme (fishCats --get theme)
            if test -n "$theme" -a "$theme" != "null"  
                echo "🎨 Theme: "(set_color cyan)$theme(set_color normal)
            end
        else
            echo "🐠 "(set_color --bold)"Fish"(set_color normal)" ready! (nixCats integration not available)"
        end
        
        echo ""
    end
end