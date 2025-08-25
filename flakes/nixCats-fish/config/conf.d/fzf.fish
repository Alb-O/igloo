# FZF integration for nixCats-fish
# This file is only loaded if fishCats('fzf') returns true

# Exit early if fzf category is not enabled (safety check)
if functions -q fishCats; and not fishCats fzf
    exit 0
end

# FZF configuration based on theme
if functions -q fishCats
    set -l theme (fishCats --get theme)
else
    set -l theme "default"
end
switch $theme
    case "tokyonight-night"
        set -gx FZF_DEFAULT_OPTS "\
--height=60% \
--layout=reverse \
--border=rounded \
--multi \
--bind=ctrl-/:toggle-preview \
--bind=ctrl-a:select-all \
--bind=ctrl-d:deselect-all \
--bind=ctrl-u:half-page-up \
--bind=ctrl-o:half-page-down \
--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7 \
--color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
        
    case "catppuccin-mocha"  
        set -gx FZF_DEFAULT_OPTS "\
--height=40% \
--layout=reverse \
--border=rounded \
--bind=ctrl-/:toggle-preview \
--color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa \
--color=fg+:#cdd6f4,bg+:#313244,hl+:#89b4fa \
--color=info:#cba6f7,prompt:#89b4fa,pointer:#f5e0dc \
--color=marker:#a6e3a1,spinner:#f5e0dc,header:#89b4fa"
        
    case '*'
        # Default FZF theme
        set -gx FZF_DEFAULT_OPTS "\
--height=40% \
--layout=reverse \
--border=rounded \
--bind=ctrl-/:toggle-preview"
end

# Default command for file searching
set -l has_modern_core false
if functions -q fishCats
    set has_modern_core (fishCats modern.core; and echo true; or echo false)
end

if test "$has_modern_core" = "true"; and command -v fd >/dev/null 2>&1
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
else if command -v rg >/dev/null 2>&1
    set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --follow --glob '!.git/*'"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
end

# Preview commands based on available tools
if test "$has_modern_core" = "true"; and command -v bat >/dev/null 2>&1
    set -gx FZF_CTRL_T_OPTS "\
--preview 'bat --style=numbers --color=always --line-range :400 {} 2>/dev/null || head -n 200 {} 2>/dev/null' \
--preview-window=right:60%:wrap"
else
    set -gx FZF_CTRL_T_OPTS "\
--preview 'head -n 200 {} 2>/dev/null' \
--preview-window=right:60%:wrap"  
end

# Directory preview
if test "$has_modern_core" = "true"; and command -v eza >/dev/null 2>&1
    set -gx FZF_ALT_C_OPTS "\
--preview 'eza --tree --level=2 {} 2>/dev/null || ls -la {} 2>/dev/null' \
--preview-window=right:50%"
else
    set -gx FZF_ALT_C_OPTS "\
--preview 'ls -la {} 2>/dev/null' \
--preview-window=right:50%"
end

# Key bindings and functions
function __fzf_history_search --description "Search command history with fzf"
    history merge
    set -l result (
        history --null | 
        fzf --read0 --print0 \
            --height=40% --layout=reverse \
            --tiebreak=index --bind=ctrl-r:toggle-sort \
            --query=(commandline) \
            --header="Press CTRL-R to toggle sort"
    )
    
    if test -n "$result"
        commandline --replace -- $result
    end
    commandline -f repaint
end

function __fzf_file_search --description "Search files with fzf"
    set -l cmd "$FZF_CTRL_T_COMMAND"
    if test -z "$cmd"
        set cmd "find . -type f 2>/dev/null | head -2000"
    end
    
    set -l result (eval "$cmd" | fzf $FZF_CTRL_T_OPTS)
    if test -n "$result"
        commandline --current-token --replace -- (string escape -- $result)
    end
    commandline -f repaint
end

function __fzf_dir_search --description "Search directories with fzf"
    set -l cmd "$FZF_ALT_C_COMMAND"
    if test -z "$cmd"
        if command -v fd >/dev/null 2>&1
            set cmd "fd --type d --hidden --follow --exclude .git . ."
        else
            set cmd "find . -type d 2>/dev/null | head -2000"
        end
    end
    
    set -l result (eval "$cmd" | fzf $FZF_ALT_C_OPTS)
    if test -n "$result"
        cd "$result"
        commandline -f repaint
    end
end

function __fzf_git_files --description "Search git files with fzf"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end
    
    set -l result (
        git ls-files | 
        fzf $FZF_CTRL_T_OPTS --header="Git tracked files"
    )
    
    if test -n "$result"
        commandline --current-token --replace -- (string escape -- $result)
    end
    commandline -f repaint
end

# Bind keys for fzf functions
bind \cr __fzf_history_search      # Ctrl+R: History search
bind \ct __fzf_file_search         # Ctrl+T: File search  
bind \ec __fzf_dir_search          # Alt+C: Directory search
bind \cg __fzf_git_files           # Ctrl+G: Git files

# Vi mode bindings (if vi mode is enabled)
if test "$fish_key_bindings" = "fish_vi_key_bindings"
    bind -M insert \cr __fzf_history_search
    bind -M insert \ct __fzf_file_search
    bind -M insert \ec __fzf_dir_search
    bind -M insert \cg __fzf_git_files
end