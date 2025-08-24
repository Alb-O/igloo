# One Dark theme for ble.sh + fzf

bleopt term_true_colors=1

# One Dark color palette
# Background: #21252b, Current Line: #2c323c, Selection: #3e4451
# Foreground: #abb2bf, Comment: #5c6370, Red: #e06c75, Orange: #d19a66
# Yellow: #e5c07b, Green: #98c379, Cyan: #56b6c2, Blue: #61afef, Purple: #c678dd

# Syntax highlighting faces
ble-face -s syntax_default 'fg=#abb2bf'
ble-face -s syntax_command 'fg=#61afef'
ble-face -s syntax_quoted 'fg=#98c379'
ble-face -s syntax_quotation 'fg=#98c379,bold'
ble-face -s syntax_escape 'fg=#c678dd'
ble-face -s syntax_comment 'fg=#5c6370'
ble-face -s syntax_param_expansion 'fg=#e5c07b'
ble-face -s syntax_varname 'fg=#d19a66'
ble-face -s syntax_delimiter 'bold'
ble-face -s syntax_error 'bg=#e06c75,fg=#21252b'

# Command highlighting faces
ble-face -s command_builtin 'fg=#e06c75'
ble-face -s command_keyword 'fg=#61afef'
ble-face -s command_function 'fg=#c678dd'
ble-face -s command_file 'fg=#98c379'
ble-face -s command_directory 'fg=#61afef,underline'

# Filename highlighting faces
ble-face -s filename_directory 'fg=#61afef,underline'
ble-face -s filename_executable 'fg=#98c379,underline'
ble-face -s filename_link 'fg=#56b6c2,underline'
ble-face -s filename_other 'underline'

# Selection and regions
ble-face -s region 'bg=#3e4451,fg=#abb2bf'
ble-face -s region_target 'bg=#61afef,fg=#21252b'
ble-face -s region_match 'bg=#e06c75,fg=#21252b'

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} \
  --color=bg+:#2c323c,bg:#21252b,spinner:#98c379,hl:#e06c75 \
  --color=fg:#abb2bf,header:#e06c75,info:#c678dd,pointer:#98c379 \
  --color=marker:#61afef,fg+:#abb2bf,prompt:#c678dd,hl+:#e06c75"
