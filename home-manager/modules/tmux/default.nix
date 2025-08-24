{
  pkgs,
  lib,
  globals,
  config,
  ...
}: let
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
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
        tmuxPlugins.tmux-sessionx
        tmuxPlugins.tokyo-night-tmux
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

        # tokyo-night-tmux preferences
        set -g @tokyo-night-tmux_time_format 12H
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
