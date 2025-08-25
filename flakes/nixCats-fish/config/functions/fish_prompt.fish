function fish_prompt --description 'Write out the prompt'
    set -l last_status $status
    set -l normal (set_color normal)
    set -l usercolor (set_color $fish_color_user 2>/dev/null; or set_color blue)
    set -l hostcolor (set_color $fish_color_host 2>/dev/null; or set_color cyan)
    set -l cwdcolor (set_color $fish_color_cwd 2>/dev/null; or set_color green)

    # Show hostname if connected via SSH
    set -l suffix
    if set -q SSH_CLIENT; or set -q SSH_CONNECTION
        set suffix "@"(set_color $hostcolor)(prompt_hostname)(set_color normal)
    end

    # Git branch info
    set -l git_branch
    if command -v git >/dev/null 2>&1; and git rev-parse --git-dir >/dev/null 2>&1
        set git_branch " "(set_color yellow)"("(git branch --show-current 2>/dev/null)")"(set_color normal)
    end

    # Status indicator
    set -l status_indicator
    if test $last_status -ne 0
        set status_indicator (set_color red)" [$last_status]"(set_color normal)
    end

    # Build the prompt
    echo -n (set_color $usercolor)(whoami)$suffix(set_color normal)":"(set_color $cwdcolor)(prompt_pwd)(set_color normal)$git_branch$status_indicator"> "
end