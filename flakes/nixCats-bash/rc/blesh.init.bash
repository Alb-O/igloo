# User ble.sh customization (safe to edit)

# Enable essential ble.sh features
bleopt highlight_syntax=1
bleopt complete_menu_style=desc
bleopt history_share=1
bleopt prompt_ps1_transient=trim

# Load prompt git sequences for optional use
if [ -r "$_NCB_CFG_DIR/blesh-contrib/prompt-git.bash" ]; then
  source "$_NCB_CFG_DIR/blesh-contrib/prompt-git.bash"
fi

# Prompt is configured in rc/prompt.bash. To enable a right-prompt, set:
#   NIXCATS_BASH_RPROMPT=git  # show git branch on the right
case "${NIXCATS_BASH_RPROMPT:-}" in
  git)
    bleopt prompt_rps1='\q{contrib/git-branch}'
    ;;
  "") ;;
  *)
    # Allow custom ble prompt sequences from env
    bleopt prompt_rps1="$NIXCATS_BASH_RPROMPT"
    ;;
esac
