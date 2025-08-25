function fish_prompt --description 'nixCats-fish prompt with git and SSH awareness'
    set -l last_status $status
    set -l normal (set_color normal)
    
    # Color scheme based on nixCats theme
    set -l theme (fishCats --get theme 2>/dev/null; or echo "default")
    
    switch $theme
        case "tokyonight-night"
            set -l usercolor (set_color 7aa2f7)      # blue
            set -l hostcolor (set_color 7dcfff)      # cyan  
            set -l cwdcolor (set_color 9ece6a)       # green
            set -l gitcolor (set_color e0af68)       # yellow
            set -l errorcolor (set_color f7768e)     # red
            
        case "catppuccin-mocha"
            set -l usercolor (set_color 89b4fa)      # blue
            set -l hostcolor (set_color 94e2d5)      # teal
            set -l cwdcolor (set_color a6e3a1)       # green  
            set -l gitcolor (set_color f9e2af)       # yellow
            set -l errorcolor (set_color f38ba8)     # red
            
        case '*'
            # Default colors
            set -l usercolor (set_color blue)
            set -l hostcolor (set_color cyan)
            set -l cwdcolor (set_color green)
            set -l gitcolor (set_color yellow)
            set -l errorcolor (set_color red)
    end
    
    # Username
    echo -n $usercolor(whoami)$normal
    
    # Show hostname if SSH connection or if explicitly requested
    if set -q SSH_CLIENT; or set -q SSH_CONNECTION; or set -q SSH_TTY
        echo -n "@"$hostcolor(prompt_hostname)$normal
    end
    
    # Current directory
    echo -n ":"$cwdcolor(prompt_pwd)$normal
    
    # Git branch info (only if git category is enabled or if in git repo)
    if fishCats git 2>/dev/null; or git rev-parse --git-dir >/dev/null 2>&1
        set -l git_branch (git branch --show-current 2>/dev/null)
        if test -n "$git_branch"
            # Check for git status indicators  
            set -l git_status ""
            
            # Check if there are staged changes
            if git diff --cached --quiet 2>/dev/null
                # No staged changes
            else
                set git_status $git_status"+"
            end
            
            # Check if there are unstaged changes  
            if git diff --quiet 2>/dev/null
                # No unstaged changes
            else
                set git_status $git_status"*"
            end
            
            # Check for untracked files
            if test -z "$(git ls-files --others --exclude-standard 2>/dev/null)"
                # No untracked files
            else
                set git_status $git_status"?"
            end
            
            echo -n " "$gitcolor"("$git_branch$git_status")"$normal
        end
    end
    
    # Status indicator for last command
    if test $last_status -ne 0
        echo -n " "$errorcolor"[$last_status]"$normal
    end
    
    # Prompt symbol
    echo -n "> "
end