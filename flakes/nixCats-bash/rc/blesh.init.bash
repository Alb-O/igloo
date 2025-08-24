# User ble.sh customization (safe to edit)

# Enable essential ble.sh features
bleopt highlight_syntax=1
bleopt complete_menu_style=desc
bleopt history_share=1

# Source git prompt from local blesh-contrib submodule
source "$_NCB_CFG_DIR/blesh-contrib/prompt-git.bash"

# Set basic left prompt and dynamic git info on the right
bleopt prompt_ps1_final='\u@\h:\w\n$ '
bleopt prompt_rps1='\q{contrib/git-branch}'
