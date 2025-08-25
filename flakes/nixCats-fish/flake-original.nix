{
  description = "nixCats-fish: A Fish shell configuration manager with category system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Simple test package first
      fishCats = pkgs.writeShellApplication {
        name = "fishCats";
        runtimeInputs = with pkgs; [fish fzf bat eza fd ripgrep];
        text = ''
          echo "🐱 nixCats-fish test package works!"
          echo "Available tools: fish, fzf, bat, eza, fd, rg"
          exec ${pkgs.fish}/bin/fish "$@"
        '';
      };
    in {
      inherit fishCats;
      default = fishCats;
    });

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [fish fzf];
        shellHook = "echo 'nixCats-fish dev shell'";
      };
    });
  };
}
