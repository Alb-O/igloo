# Catppuccin Mocha theme for ble.sh + fzf

# Prefer truecolor
bleopt term_true_colors=1

# Catppuccin Mocha color palette (hex values)
# Base: #1e1e2e, Mantle: #181825, Surface0: #313244, Surface1: #45475a
# Text: #cdd6f4, Subtext1: #bac2de, Subtext0: #a6adc8, Overlay2: #9399b2
# Blue: #89b4fa, Lavender: #b4befe, Sapphire: #74c7ec, Sky: #89dceb
# Teal: #94e2d5, Green: #a6e3a1, Yellow: #f9e2af, Peach: #fab387
# Maroon: #eba0ac, Red: #f38ba8, Mauve: #cba6f7, Pink: #f5c2e7
# Flamingo: #f2cdcd, Rosewater: #f5e0dc

# Syntax highlighting faces
ble-face -s syntax_default 'fg=#cdd6f4'
ble-face -s syntax_command 'fg=#89b4fa'
ble-face -s syntax_quoted 'fg=#a6e3a1'
ble-face -s syntax_quotation 'fg=#a6e3a1,bold'
ble-face -s syntax_escape 'fg=#cba6f7'
ble-face -s syntax_comment 'fg=#6c7086'
ble-face -s syntax_param_expansion 'fg=#f9e2af'
ble-face -s syntax_varname 'fg=#fab387'
ble-face -s syntax_delimiter 'bold'
ble-face -s syntax_error 'bg=#f38ba8,fg=#1e1e2e'

# Command highlighting faces
ble-face -s command_builtin 'fg=#f38ba8'
ble-face -s command_keyword 'fg=#89b4fa'
ble-face -s command_function 'fg=#cba6f7'
ble-face -s command_file 'fg=#a6e3a1'
ble-face -s command_directory 'fg=#89b4fa,underline'

# Filename highlighting faces  
ble-face -s filename_directory 'fg=#89b4fa,underline'
ble-face -s filename_executable 'fg=#a6e3a1,underline'
ble-face -s filename_link 'fg=#94e2d5,underline'
ble-face -s filename_other 'underline'

# Selection and regions
ble-face -s region 'bg=#45475a,fg=#cdd6f4'
ble-face -s region_target 'bg=#89b4fa,fg=#1e1e2e'
ble-face -s region_match 'bg=#f38ba8,fg=#1e1e2e'

# FZF colors for Catppuccin Mocha
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
