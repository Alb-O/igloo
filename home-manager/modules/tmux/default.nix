{
  pkgs,
  lib,
  globals,
  config,
  ...
}: let
  theme = import ../../lib/themes/default.nix globals;
  capabilities = import ../../lib/capabilities.nix {inherit pkgs globals;};
in {
  options.igloo.tmux.enable =
    lib.mkEnableOption "Enable tmux configuration"
    // {
      default = true;
    };
  options.igloo.tmux.pickers.enable =
    lib.mkEnableOption "Enable fzf-based tmux pickers (F1–F4)"
    // {
      default = globals.system.isGraphical;
    };

  config = lib.mkIf config.igloo.tmux.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      # Stop tmux+escape craziness.
      escapeTime = 0;
      # Force tmux to use /tmp for sockets (WSL2 compat)
      secureSocket = false;
      # Use XDG-compliant directory
      historyLimit = 3000;

      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.mode-indicator
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
        tmuxPlugins.tmux-sessionx
      ];

      extraConfig = let
        pickerBinds =
          if config.igloo.tmux.pickers.enable
          then ''
            # Custom fzf pickers
            bind-key F1 run-shell "tmux-app-launcher"
            bind-key F2 run-shell "tmux-cliphist"
            bind-key F3 run-shell "tmux-unicode"
            bind-key F4 run-shell "tmux-system-menu"
          ''
          else '''';
      in ''
        set -g default-shell ${pkgs.bash}/bin/bash
        # Start panes as login shells so they read ~/.profile
        set -g default-command "${pkgs.bash}/bin/bash -l"

        set -g prefix f2
        bind f2 send-prefix

        # Color theme from semantic theme system
        highlight_color='${theme.ui.interactive.primary}'
        muted_color='${theme.ui.border.secondary}'
        text_color='${theme.ui.foreground.primary}'
        bg_color='${theme.ui.background.primary}'

        # Set base index to 1 (easier to navigate)
        set -g base-index 1

        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        set -g default-terminal "screen-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides ",alacritty:RGB"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set-environment -g COLORTERM "truecolor"
        set-option -sa terminal-features ',*:RGB'

        set -g allow-passthrough all

        set-environment -g TMUX_PLUGIN_MANAGER_PATH '${globals.dirs.localShare}/tmux/plugins'

        # Move tmux data to XDG-compliant location
        set -g @resurrect-dir '${globals.dirs.localShare}/tmux/resurrect'

        # Mouse works as expected
        set-option -g mouse on

        # Easy config reload
        bind-key R source-file ~/.config/tmux/tmux.conf \; display-message "tmux.conf reloaded."

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
        set -g status-right "#[fg=${theme.ui.foreground.tertiary}]%m/%d %I:%M %p #{tmux_mode_indicator}"
        set -g window-status-current-style "bg=$highlight_color,fg=$bg_color,bold"
        set -g window-status-style "fg=$text_color"
        set -g window-status-format ' #I:#W '
        set -g window-status-current-format ' #I:#W '

        # Key bindings from vim-style config
        bind-key : command-prompt
        bind-key r refresh-client
        bind-key L clear-history

        bind-key space next-window
        bind-key bspace previous-window
        bind-key enter next-layout

        # Split pane commands (keep existing but add alternate bindings)
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind h split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # Vim-like pane navigation
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R

        # Smart pane switching with awareness of vim splits
        bind -n C-h run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-h) || tmux select-pane -L"
        bind -n C-j run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-j) || tmux select-pane -D"
        bind -n C-k run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-k) || tmux select-pane -U"
        bind -n C-l run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-l) || tmux select-pane -R"
        bind -n 'C-\' run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys 'C-\\') || tmux select-pane -l"
        bind C-l send-keys 'C-l'

        bind-key C-o rotate-window

        # Layout bindings
        bind-key + select-layout main-horizontal
        bind-key = select-layout main-vertical

        # Window and pane settings
        set-window-option -g other-pane-height 25
        set-window-option -g other-pane-width 80
        set-window-option -g display-panes-time 1500

        # Additional navigation bindings
        bind-key a last-pane
        bind-key q display-panes
        bind-key t next-window
        bind-key T previous-window

        # Copy mode bindings
        bind-key [ copy-mode
        bind-key ] paste-buffer

        # Setup 'v' to begin selection as in Vim
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "${capabilities.copyCmd}"

        # Update default binding of Enter to also use copy-pipe
        unbind -T copy-mode-vi Enter
        bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "${capabilities.copyCmd}"

        # Don't ask before killing panes/windows
        bind x kill-pane
        bind & kill-window

          ${pickerBinds}

        # Set window notifications
        setw -g monitor-activity on
        set -g visual-activity on

        # Allow the arrow key to be used immediately after changing windows
        set-option -g repeat-time 0

        # continuum auto-restore and save interval
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '5'

        # Force plugin initialization
        run-shell '${pkgs.tmuxPlugins.mode-indicator}/share/tmux-plugins/mode-indicator/mode_indicator.tmux'
      '';
    };

    home.packages = [
      pkgs.tmux-fzf-tools
      # Open tmux for current project.
      (pkgs.writeShellApplication {
        name = "pux";
        runtimeInputs = [pkgs.tmux];
        text = ''
          PRJ="''$(zoxide query -i)"
          echo "Launching tmux for ''$PRJ"
          set -x
          cd "''$PRJ" && \
            exec tmux -S "''$PRJ".tmux attach
        '';
      })
    ];
  };
}
