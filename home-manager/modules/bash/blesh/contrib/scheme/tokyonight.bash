# Scheme Inspired by Tokyo Night
# https://github.com/tokyo-night/tokyo-night-vscode-theme
# A clean, dark theme that celebrates the lights of Downtown Tokyo at night.
# Custom theme for blesh terminal

function ble/contrib/scheme:tokyonight/initialize {
  # Reset all faces to default first (replaces the default scheme dependency)
  ble-face -r region region_@
  ble-face -r disabled
  ble-face -r overwrite_mode
  ble-face -r vbell vbell_@
  ble-face -r syntax_@
  ble-face -r command_@
  ble-face -r filename_@
  ble-face -r varname_@
  ble-face -r argument_@
  ble-face -r prompt_status_line
  ble-face -r cmdinfo_cd_cdpath
  ble-face -r auto_complete
  ble-face -r menu_filter_fixed
  ble-face -r menu_filter_input
  ble-face -r menu_desc_default
  ble-face -r menu_desc_type
  ble-face -r menu_desc_quote
  
  # Debug: Print message when theme loads
  echo "Tokyo Night theme is being loaded..." >&2

  # Tokyo Night Color Palette:
  # Red:    #f7768e  Pink:      #bb9af7  Cyan:     #7dcfff
  # Orange: #ff9e64  Blue:      #7aa2f7  White:    #c0caf5
  # Yellow: #e0af68  Teal:      #73daca  Gray:     #a9b1d6
  # Green:  #9ece6a  Light Blue:#2ac3de  Comments: #565f89
  # Background: #1a1b26 (Night) / #24283b (Storm)

  ble-face -s argument_error 'fg=#f7768e'                        # Red text only
  ble-face -s argument_option 'fg=#bb9af7,italic'               # Pink/Purple
  ble-face -s auto_complete 'fg=#565f89,italic'                 # Comments color
  ble-face -s cmdinfo_cd_cdpath 'fg=#565f89,italic'             # Dimmed text for cd path
  ble-face -s command_alias 'fg=#2ac3de'                        # Light blue
  ble-face -s command_builtin 'fg=#ff9e64'                      # Orange
  ble-face -s command_directory 'fg=#7aa2f7'                    # Blue
  ble-face -s command_file 'fg=#2ac3de'                         # Light blue
  ble-face -s command_function 'fg=#7aa2f7'                     # Blue
  ble-face -s command_keyword 'fg=#bb9af7'                      # Pink/Purple
  ble-face -s disabled 'fg=#414868'                             # Dark gray
  ble-face -s filename_directory 'fg=#7aa2f7'                   # Blue
  ble-face -s filename_directory_sticky 'fg=#1a1b26,bg=#9ece6a' # Dark on green
  ble-face -s filename_executable 'fg=#9ece6a,bold'             # Green
  ble-face -s filename_ls_colors 'none'
  ble-face -s filename_orphan 'fg=#7dcfff,bold'                 # Cyan
  ble-face -s filename_other 'none'
  ble-face -s filename_setgid 'fg=#e0af68,underline'             # Yellow with underline
  ble-face -s filename_setuid 'fg=#ff9e64,underline'            # Orange with underline
  ble-face -s menu_filter_input 'fg=#e0af68'                    # Yellow text only
  ble-face -s overwrite_mode 'fg=#7dcfff'                       # Cyan text only
  ble-face -s prompt_status_line 'bg=#565f89'                   # Comments color
  ble-face -s region 'bg=#414868'                               # Dark gray
  ble-face -s region_insert 'bg=#414868'                        # Dark gray
  ble-face -s region_match 'bg=#e0af68'                          # Yellow background for selections
  ble-face -s region_target 'bg=#bb9af7'                        # Pink/purple background for selections
  ble-face -s syntax_brace 'fg=#9aa5ce'                         # Medium gray
  ble-face -s syntax_command 'fg=#2ac3de'                       # Light blue
  ble-face -s syntax_comment 'fg=#565f89'                       # Comments color
  ble-face -s syntax_delimiter 'fg=#9aa5ce'                     # Medium gray
  ble-face -s syntax_document 'fg=#c0caf5,bold'                 # White
  ble-face -s syntax_document_begin 'fg=#c0caf5,bold'           # White
  ble-face -s syntax_error 'fg=#f7768e'                          # Red text only
  ble-face -s syntax_escape 'fg=#73daca'                        # Teal
  ble-face -s syntax_expr 'fg=#bb9af7'                          # Pink/Purple
  ble-face -s syntax_function_name 'fg=#7aa2f7'                 # Blue
  ble-face -s syntax_glob 'fg=#ff9e64'                          # Orange
  ble-face -s syntax_history_expansion 'fg=#7aa2f7,italic'      # Blue
  ble-face -s syntax_param_expansion 'fg=#f7768e'               # Red
  ble-face -s syntax_quotation 'fg=#9ece6a'                     # Green
  ble-face -s syntax_tilde 'fg=#bb9af7'                         # Pink/Purple
  ble-face -s syntax_varname 'fg=#c0caf5'                       # White
  ble-face -s varname_array 'fg=#ff9e64'                        # Orange
  ble-face -s varname_empty 'fg=#ff9e64'                        # Orange
  ble-face -s varname_export 'fg=#ff9e64'                       # Orange
  ble-face -s varname_expr 'fg=#ff9e64'                         # Orange
  ble-face -s varname_hash 'fg=#ff9e64'                         # Orange
  ble-face -s varname_number 'fg=#e0af68'                       # Yellow
  ble-face -s varname_readonly 'fg=#ff9e64'                     # Orange
  ble-face -s varname_transform 'fg=#ff9e64'                    # Orange
  ble-face -s varname_unset 'fg=#f7768e'                         # Red text only
  ble-face -s vbell_erase 'bg=#414868'                          # Dark gray
}