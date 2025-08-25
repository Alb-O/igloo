# Git-specific configuration for nixCats-fish
# This file is only loaded if fishCats('git') or fishCats('development') returns true

# Exit early if neither git nor development category is enabled
if functions -q fishCats; and not fishCats git; and not fishCats development
    exit 0
end

# Git configuration and aliases
if command -v git >/dev/null 2>&1
    # Enhanced git log aliases
    alias glog "git log --oneline --decorate --graph --all"
    alias glogp "git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
    alias glogs "git log --stat --abbrev-commit"
    
    # Git status and info
    alias gst "git status --short --branch"
    alias gss "git status"
    alias ginfo "git remote -v && echo && git branch -a"
    
    # Git branch management
    alias gcb "git checkout -b"
    alias gbd "git branch -d"
    alias gbD "git branch -D"
    alias gbr "git branch -r"
    alias gba "git branch -a"
    
    # Git commit shortcuts
    alias gcm "git commit -m"
    alias gca "git commit -a"
    alias gcam "git commit -a -m"
    alias gc! "git commit --amend"
    alias gcn! "git commit --no-edit --amend"
    
    # Git diff aliases
    alias gd "git diff"
    alias gdc "git diff --cached"
    alias gdw "git diff --word-diff"
    alias gds "git diff --stat"
    
    # Git add variants
    alias ga "git add"
    alias gaa "git add --all"
    alias gap "git add --patch"
    alias gau "git add --update"
    
    # Git push/pull shortcuts
    alias gp "git push"
    alias gpf "git push --force-with-lease"
    alias gpl "git pull"
    alias gplr "git pull --rebase"
    alias gpu "git push --set-upstream origin"
    
    # Git stash management
    alias gsta "git stash"
    alias gstl "git stash list"
    alias gstp "git stash pop"
    alias gstd "git stash drop"
    alias gsts "git stash show"
    
    # Git reset shortcuts (be careful!)
    alias grh "git reset HEAD"
    alias grhh "git reset HEAD --hard"
    alias groh "git reset --hard origin/HEAD"
    
    # Git navigation
    alias gco "git checkout"
    alias gcom "git checkout main 2>/dev/null || git checkout master"
    alias gcod "git checkout develop"
    
    # Git utilities
    alias gclean "git clean -fd"
    alias gprune "git remote prune origin"
    alias gtags "git tag -l"
    alias gignore "git update-index --assume-unchanged"
    alias gunignore "git update-index --no-assume-unchanged"
    
    # Quick commit with current timestamp
    function gcts --description "Quick commit with timestamp"
        git add -A && git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" $argv
    end
    
    # Create and switch to new branch from current branch  
    function gnb --description "Create new branch from current branch"
        if test (count $argv) -eq 0
            echo "Usage: gnb <branch-name>"
            return 1
        end
        git checkout -b $argv[1]
    end
    
    # Show git log since yesterday (useful for standup)
    function gtoday --description "Git commits since yesterday"
        git log --since="yesterday" --oneline --author=(git config user.email)
    end
    
    # Interactive git add with preview
    function gai --description "Interactive git add with fzf"
        if command -v fzf >/dev/null 2>&1
            git status --porcelain | fzf --multi --preview 'git diff --color=always {2}' | awk '{print $2}' | xargs git add
        else
            git add --interactive
        end
    end
    
    # Show what's been committed but not pushed
    function gupstream --description "Show commits ahead of upstream"
        set -l branch (git branch --show-current)
        git log --oneline origin/$branch..$branch
    end
end