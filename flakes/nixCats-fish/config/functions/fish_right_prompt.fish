function fish_right_prompt --description 'Right-side prompt for nixCats-fish'
    set -l normal (set_color normal)
    
    # Get theme colors
    set -l theme (fishCats --get theme 2>/dev/null; or echo "default")
    
    switch $theme  
        case "tokyonight-night"
            set -l timecolor (set_color 565f89)      # comment color
            set -l nixcolor (set_color bb9af7)       # purple
            
        case "catppuccin-mocha"
            set -l timecolor (set_color 6c7086)      # overlay0
            set -l nixcolor (set_color cba6f7)       # mauve
            
        case '*'
            set -l timecolor (set_color brblack)
            set -l nixcolor (set_color magenta)
    end
    
    set -l components ""
    
    # Show nixCats package name if different from fishCats
    set -l package_name (fishCats --get packageName 2>/dev/null)
    if test -n "$package_name" -a "$package_name" != "fishCats"
        set components $components$nixcolor"⚡$package_name"$normal
    end
    
    # Add separator if we have components
    if test -n "$components"
        set components $components" "
    end
    
    # Current time
    set components $components$timecolor(date '+%H:%M:%S')$normal
    
    echo -n $components
end