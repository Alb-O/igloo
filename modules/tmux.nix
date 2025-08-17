{ pkgs, globals, ... }:
let
  theme = import ../lib/themes/default.nix globals;
in
{
  programs.tmux = {
    enable = true;
    shortcut = "q";
    # aggssiveResize = true; -- Disabled to be iTerendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.tmux-sessionx
    ];

    extraConfig = ''
      # Color theme from semantic theme system
      highlight_color='${theme.ui.interactive.primary}'
      muted_color='${theme.ui.border.secondary}'
      text_color='${theme.ui.foreground.primary}'
      bg_color='${theme.ui.background.primary}'

      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",alacritty:RGB"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"
      set-option -sa terminal-features ',*:RGB'

      # Mouse works as expected
      set-option -g mouse on

      # Comprehensive theming
      set -g mode-style "fg=$bg_color,bg=$highlight_color"
      set -g message-style "fg=$bg_color,bg=$highlight_color"
      set -g message-command-style "fg=$bg_color,bg=$highlight_color"
      set -g clock-mode-colour "$highlight_color"

      # Pane identification - clearer active pane indication
      set -g pane-border-style "fg=$muted_color"
      set -g pane-active-border-style "fg=$highlight_color"

      # Pane titles to show which is active
      set -g pane-border-status top
      set -g pane-border-format "#{?pane_active,#[fg=$highlight_color],#[fg=$muted_color]} #{pane_index} #[default]"

      # Status bar at top showing windows/tabs
      set -g status on
      set -g status-position top
      set -g status-style "bg=default,fg=$text_color"
      set -g status-justify absolute-centre
      set -g status-left-length 50
      set -g status-right-length 50
      set -g status-left "#[fg=${theme.ui.foreground.tertiary}]#S #(cd #{pane_current_path}; git branch --show-current 2>/dev/null) "
      set -g status-right "#[fg=${theme.ui.foreground.tertiary}]%m/%d %I:%M %p"
      set -g window-status-current-style "bg=$highlight_color,fg=$bg_color,bold"
      set -g window-status-style "fg=$text_color"
      set -g window-status-format ' #I:#W '
      set -g window-status-current-format ' #I:#W '

      # Split pane commands
      bind v split-window -h -c "#{pane_current_path}"
      bind h split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Don't ask before killing panes/windows
      bind x kill-pane
      bind & kill-window
         
      # continuum auto-restore and save interval
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '5'
    '';
  };

  home.packages = [
    # Open tmux for current project.
    (pkgs.writeShellApplication {
      name = "pux";
      runtimeInputs = [ pkgs.tmux ];
      text = ''
        PRJ="''$(zoxide query -i)"
        echo "Launching tmux for ''$PRJ"
        set -x
        cd "''$PRJ" && \
          exec tmux -S "''$PRJ".tmux attach
      '';
    })
  ];
}
