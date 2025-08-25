# Utility functions for nixCats-fish
# This file is only loaded if fishCats('utilities') returns true

# Exit early if utilities category is not enabled
if functions -q fishCats; and not fishCats utilities
    exit 0
end

# Improved directory listing aliases with better defaults
if command -v eza >/dev/null 2>&1
    alias ls "eza --icons=auto --group-directories-first"
    alias ll "eza --icons=auto --group-directories-first -la"
    alias la "eza --icons=auto --group-directories-first -a"
    alias lt "eza --icons=auto --tree"
    alias lg "eza --icons=auto --group-directories-first -la --git"
end

# Basic git shortcut (detailed git aliases are in git.fish)
if command -v git >/dev/null 2>&1
    alias g git
end

# Directory navigation shortcuts
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias ..... "cd ../../../.."
alias cdh "cd ~"
alias cdb "cd -"

# File operations with safety
alias cp "cp -iv"
alias mv "mv -iv" 
alias rm "rm -iv"
alias mkdir "mkdir -pv"

# Network shortcuts
alias myip "curl -s ifconfig.me"
alias localip "ip route get 1 | awk '{print \$NF; exit}'"
alias ports "ss -tuln"

# Quick file editing  
alias e '$EDITOR'
alias v '$EDITOR'

# Process management
alias psg "ps aux | grep -v grep | grep -i -E"
alias h "history | tail -20"

# Disk usage shortcuts
if command -v dust >/dev/null 2>&1
    alias du dust
    alias duh "dust -d 1"
else
    alias duh "du -sh * | sort -hr"
end