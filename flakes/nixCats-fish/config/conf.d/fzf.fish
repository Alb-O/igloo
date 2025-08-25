# FZF integration for Fish

# FZF configuration
set -gx FZF_DEFAULT_OPTS "\
--height=40% \
--layout=reverse \
--border \
--bind=ctrl-/:toggle-preview \
--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7 \
--color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"

# Default command for fzf
if command -v fd >/dev/null 2>&1
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
else if command -v rg >/dev/null 2>&1
    set -gx FZF_DEFAULT_COMMAND "rg --files"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
end

# Preview command
if command -v bat >/dev/null 2>&1
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :400 {} 2>/dev/null || head -n 200 {} 2>/dev/null'"
else
    set -gx FZF_CTRL_T_OPTS "--preview 'head -n 200 {} 2>/dev/null'"
end

# Directory preview
set -gx FZF_ALT_C_OPTS "--preview 'eza -T {} | head -200'"

# History search (Ctrl+R)
function __fzf_history_search
    history merge
    history -z | fzf --read0 --print0 \
        --height=40% --layout=reverse \
        --tiebreak=index --bind=ctrl-r:toggle-sort \
        --query=(commandline) \
        --bind=ctrl-x:toggle+down \
        | read -lz result
    and commandline -- $result
    commandline -f repaint
end

# File search (Ctrl+T)
function __fzf_file_search
    set -l cmd "$FZF_CTRL_T_COMMAND"
    if test -z "$cmd"
        set cmd "find . -type f 2>/dev/null | head -2000"
    end
    eval "$cmd" | fzf $FZF_CTRL_T_OPTS | while read -l item
        echo -n "$item "
    end | read -z result
    commandline -i -- $result
    commandline -f repaint
end

# Directory search (Alt+C)
function __fzf_dir_search
    set -l cmd "find . -type d 2>/dev/null | head -2000"
    if command -v fd >/dev/null 2>&1
        set cmd "fd --type d --hidden --follow --exclude .git"
    end
    eval "$cmd" | fzf $FZF_ALT_C_OPTS | read -l result
    if test -n "$result"
        cd "$result"
        commandline -f repaint
    end
end

# Git file search
function __fzf_git_files
    if git rev-parse --git-dir >/dev/null 2>&1
        git ls-files | fzf $FZF_CTRL_T_OPTS | while read -l item
            echo -n "$item "
        end | read -z result
        commandline -i -- $result
        commandline -f repaint
    end
end

# Key bindings
bind \cr __fzf_history_search
bind \ct __fzf_file_search
bind \ec __fzf_dir_search
bind \cg __fzf_git_files

# Alt bindings (if terminal supports them)
bind \e\[1\;3A __fzf_history_search  # Alt+Up
bind \e\[1\;3D __fzf_dir_search      # Alt+Left