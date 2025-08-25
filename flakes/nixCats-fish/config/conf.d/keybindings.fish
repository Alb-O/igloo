# Key bindings for nixCats-fish
# Provides useful shortcuts and bindings for productivity

# Better history search with up/down arrows
bind -k up history-search-backward
bind -k down history-search-forward

# Alt+. to get the last argument from previous command (like bash)  
bind \e. history-token-search-backward

# Ctrl+L to clear screen (standard)
bind \cl 'clear; commandline -f repaint'

# Ctrl+U to clear line before cursor
bind \cu backward-kill-line

# Ctrl+K to clear line after cursor  
bind \ck kill-line

# Ctrl+W to delete word backward
bind \cw backward-kill-word

# Alt+D to delete word forward
bind \ed kill-word

# Ctrl+Left/Right to move by words
bind \e\[1\;5C forward-word
bind \e\[1\;5D backward-word

# Alt+Left/Right to move by words (alternative)
bind \e\[1\;3C forward-word
bind \e\[1\;3D backward-word

# Ctrl+A and Ctrl+E for beginning/end of line (emacs-style even in vi mode)
bind \ca beginning-of-line
bind \ce end-of-line

# Vi mode specific bindings (only apply if vi mode is active)
if test "$fish_key_bindings" = "fish_vi_key_bindings"
    # In vi mode, bind 'jj' to escape to normal mode
    bind -M insert jj "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"
    
    # 'v' in normal mode to edit command line in editor
    bind -M default v edit_command_buffer
    
    # Better increment/decrement in normal mode
    bind -M default \cx\ca 'commandline -i (math (commandline -t) + 1)'
    bind -M default \cx\cx 'commandline -i (math (commandline -t) - 1)'
end

# Function to toggle between insert and normal mode indicators
function __fish_mode_prompt --description 'Display vi mode'
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        switch $fish_bind_mode
            case default
                set_color --bold yellow
                echo '[N] '
            case insert
                set_color --bold green  
                echo '[I] '
            case visual
                set_color --bold magenta
                echo '[V] '
            case replace_one replace
                set_color --bold red
                echo '[R] '
        end
        set_color normal
    end
end

# Directory shortcuts with Alt+number
bind \e1 'cd ~'
bind \e2 'cd ..'
bind \e3 'cd ../..'
bind \e4 'cd ../../..'

# Quick edit configurations
function edit-fish-config --description 'Edit fish config'
    $EDITOR $__fish_config_dir/config.fish
end

function edit-fish-aliases --description 'Edit fish aliases'  
    $EDITOR $__fish_config_dir/conf.d/utilities.fish
end

function reload-fish --description 'Reload fish configuration'
    source $__fish_config_dir/config.fish
    echo "Fish configuration reloaded!"
end

# Bind F5 to reload config
bind \e\[15~ reload-fish