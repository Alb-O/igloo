# Development tools configuration for nixCats-fish
# This file is only loaded if fishCats('development') returns true

# Exit early if development category is not enabled
if functions -q fishCats; and not fishCats development
    exit 0
end

# Direnv integration for automatic environment loading
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
    
    # Quick direnv shortcuts
    alias da "direnv allow"
    alias dr "direnv reload" 
    alias ds "direnv status"
end

# Just (task runner) shortcuts
if command -v just >/dev/null 2>&1
    alias j just
    alias jl "just --list"
    alias je "just --edit"
    alias jc "just --choose"
    
    # Enable just completions if available
    if test -f (just --completions fish | psub)
        just --completions fish | source
    end
end

# Docker shortcuts (if docker is available)
if command -v docker >/dev/null 2>&1
    alias d docker
    alias dc "docker-compose"
    alias dcu "docker-compose up"
    alias dcd "docker-compose down"
    alias dcr "docker-compose restart"
    alias dcl "docker-compose logs"
    alias dclf "docker-compose logs -f"
    alias dps "docker ps"
    alias dpsa "docker ps -a"
    alias di "docker images"
    alias drmi "docker rmi"
    alias drmif "docker rmi -f"
    alias drm "docker rm"
    alias drmf "docker rm -f"
    
    # Docker cleanup functions
    function docker-clean-containers --description "Remove all stopped containers"
        docker container prune -f
    end
    
    function docker-clean-images --description "Remove dangling images"
        docker image prune -f
    end
    
    function docker-clean-all --description "Full docker cleanup"
        docker system prune -af --volumes
    end
end

# Nix development shortcuts
if command -v nix >/dev/null 2>&1
    alias nb "nix build"
    alias nr "nix run"
    alias nd "nix develop"
    alias nf "nix flake"
    alias nfl "nix flake lock"
    alias nfu "nix flake update"
    alias nfc "nix flake check"
    alias nfs "nix flake show"
    alias ns "nix search nixpkgs"
    alias nsh "nix-shell"
    
    # Nix garbage collection
    alias ngc "nix-collect-garbage"
    alias ngcd "nix-collect-garbage -d"
    alias sudo-ngc "sudo nix-collect-garbage"
    alias sudo-ngcd "sudo nix-collect-garbage -d"
    
    function nix-which --description "Show which package provides a command"
        nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root "/bin/$argv[1]"
    end
end

# Python development shortcuts
if command -v python3 >/dev/null 2>&1
    alias py python3
    alias pip pip3
    alias venv "python3 -m venv"
    alias serve "python3 -m http.server"
    alias json "python3 -m json.tool"
    
    # Virtual environment helpers
    function venv-activate --description "Activate Python virtual environment"
        if test -d venv
            source venv/bin/activate.fish
        else if test -d .venv
            source .venv/bin/activate.fish  
        else
            echo "No virtual environment found (looking for 'venv' or '.venv')"
            return 1
        end
    end
    
    alias va venv-activate
end

# Node.js development shortcuts
if command -v node >/dev/null 2>&1
    alias n node
    alias ni "npm install"
    alias nis "npm install --save"
    alias nid "npm install --save-dev"
    alias nr "npm run"
    alias ns "npm start"
    alias nt "npm test"
    alias nb "npm run build"
    alias nw "npm run watch"
    alias nf "npm run format"
    alias nl "npm run lint"
    alias nc "npm run check"
    
    # Quick package.json inspection
    function pkg --description "Show package.json scripts and dependencies"
        if test -f package.json
            echo "📦 Scripts:"
            jq -r '.scripts | to_entries[] | "  \(.key): \(.value)"' package.json 2>/dev/null
            echo
            echo "🔗 Dependencies:"  
            jq -r '.dependencies // {} | to_entries[] | "  \(.key): \(.value)"' package.json 2>/dev/null
        else
            echo "No package.json found in current directory"
        end
    end
end

# Rust development shortcuts  
if command -v cargo >/dev/null 2>&1
    alias c cargo
    alias cb "cargo build"
    alias cr "cargo run"
    alias ct "cargo test"
    alias cc "cargo check"
    alias cf "cargo fmt"
    alias cl "cargo clippy"
    alias cu "cargo update"
    alias cw "cargo watch"
    alias ci "cargo install"
    alias cid "cargo install --debug"
end

# Go development shortcuts
if command -v go >/dev/null 2>&1
    alias gob "go build"
    alias gor "go run"
    alias got "go test"
    alias gof "go fmt"
    alias gom "go mod"
    alias gomi "go mod init"
    alias gomt "go mod tidy"
    alias gomv "go mod vendor"
    alias goi "go install"
end

# Editor shortcuts
alias e '$EDITOR'
alias v '$EDITOR'  
alias vim '$EDITOR'
alias code '$EDITOR'

# Quick project navigation (if in a git repo)
function project-root --description "Go to project root (git repo root)"
    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -eq 0
        cd $root
    else
        echo "Not in a git repository"
        return 1
    end
end

alias pr project-root