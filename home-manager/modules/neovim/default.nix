{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Import neovim-nightly overlay for this module
  nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlays.default];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Use nightly neovim from overlay
    package = pkgs.neovim;

    extraLuaConfig = builtins.readFile ./init.lua;

    extraPackages = with pkgs; [
      # Language servers
      lua-language-server

      # Additional tools that might be needed
      ripgrep
      fd
    ];
  };

  # Copy Lua configuration files to the right location
  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  # Copy LSP configuration files
  xdg.configFile."nvim/lsp" = {
    source = ./lsp;
    recursive = true;
  };

  # Explicitly manage nvim/init.lua to prevent accidental overrides
  xdg.configFile."nvim/init.lua" = {
    text = builtins.readFile ./init.lua;
    force = true;
  };

  # Install nvimpager
  home.packages = with pkgs; [
    nvimpager
  ];

  # Provide the colorscheme plugin directly from the store to avoid
  # referencing Neovim's data dir in nvimpager.
  xdg.configFile."nvimpager/pack/deps/start/tokyonight.nvim" = {
    source = pkgs.vimPlugins.tokyonight-nvim;
  };

  # Configure nvimpager with colorscheme only
  xdg.configFile."nvimpager/init.lua".text = ''
    vim.cmd[[colorscheme tokyonight-night]]
  '';

  # Ensure nvimpager uses its own appname without affecting regular nvim.
  # Put a small wrapper early in PATH that sets NVIM_APPNAME only for nvimpager.
  home.file.".local/bin/nvimpager" = {
    text = ''
      #!/usr/bin/env bash
      export NVIM_APPNAME=nvimpager
      exec "${pkgs.nvimpager}/bin/nvimpager" "$@"
    '';
    executable = true;
  };

  # Ensure the main nvim always uses its own appname explicitly
  home.file.".local/bin/nvim" = {
    text = ''
      #!/usr/bin/env bash
      export NVIM_APPNAME=nvim
      exec "${pkgs.neovim}/bin/nvim" "$@"
    '';
    executable = true;
  };

  # Guard against an accidental symlink of nvimpager -> nvim under the config dir
  # so these two configs remain isolated.
  home.activation.fixNvimpagerConfigDir = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    set -eu
    conf_dir="${config.xdg.configHome or "$HOME/.config"}"
    nvimpager_path="$conf_dir/nvimpager"
    nvim_path="$conf_dir/nvim"
    if [ -L "$nvimpager_path" ]; then
      target="$(readlink -f "$nvimpager_path" || true)"
      if [ "$target" = "$nvim_path" ]; then
        rm -f "$nvimpager_path"
        mkdir -p "$nvimpager_path"
      fi
    fi
  '';
}
