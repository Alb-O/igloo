function fish_right_prompt --description 'Write out the right side of the prompt'
    # Show current time
    set_color brblack
    echo -n (date '+%H:%M:%S')
    set_color normal
end