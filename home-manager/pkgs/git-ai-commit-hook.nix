{ pkgs, ... }:

pkgs.writeShellScriptBin "git-ai-commit-hook" ''
    #!/bin/bash
    
    # This script is used as a prepare-commit-msg hook
    # It adds comprehensive AI context to commit messages
    
    COMMIT_MSG_FILE="$1"
    COMMIT_SOURCE="$2"
    SHA1="$3"
    
    # Only run for regular commits (not merges, rebases, squashes, etc.)
    if [ -z "$COMMIT_SOURCE" ] || [ "$COMMIT_SOURCE" = "message" ]; then
        # Create a temporary file with the enhanced commit message
        TEMP_FILE=$(mktemp)
        
        # Copy original commit message (preserving any pre-filled content)
        cp "$COMMIT_MSG_FILE" "$TEMP_FILE"
        
        # Add comprehensive context information
        cat >> "$TEMP_FILE" << 'EOF'

  # === CONTEXT ===

  EOF
        
        # Recent commit history
        echo "# Recent commits (last 8):" >> "$TEMP_FILE"
        if git log --oneline -8 2>/dev/null | head -8; then
            git log --oneline -8 2>/dev/null | head -8 | sed 's/^/# /' >> "$TEMP_FILE"
        else
            echo "# No recent commits available" >> "$TEMP_FILE"
        fi
        
        # Change statistics
        echo "#" >> "$TEMP_FILE"
        echo "# Change summary:" >> "$TEMP_FILE"
        if git diff --cached --stat 2>/dev/null; then
            git diff --cached --stat 2>/dev/null | sed 's/^/# /' >> "$TEMP_FILE"
        else
            echo "# No staged changes" >> "$TEMP_FILE"
        fi
        
        # Show recent commits with their changes for context
        echo "#" >> "$TEMP_FILE"
        echo "# Recent commits with changes (for context):" >> "$TEMP_FILE"
        if git log -3 --pretty=format:"%h - %an - %s" --stat 2>/dev/null; then
            git log -3 --pretty=format:"%h - %an - %s" --stat 2>/dev/null | sed 's/^/# /' >> "$TEMP_FILE"
        else
            echo "# No commit history available" >> "$TEMP_FILE"
        fi
        
        # Detailed diff (limited to avoid huge commits)
        echo "#" >> "$TEMP_FILE"
        echo "# Detailed diff (first 50 lines):" >> "$TEMP_FILE"
        if git diff --cached 2>/dev/null | head -50; then
            git diff --cached 2>/dev/null | head -50 | sed 's/^/# /' >> "$TEMP_FILE"
        else
            echo "# No diff available" >> "$TEMP_FILE"
        fi
        
        # Working directory status
        echo "#" >> "$TEMP_FILE"
        echo "# Repository status:" >> "$TEMP_FILE"
        if git status --porcelain 2>/dev/null; then
            git status --porcelain 2>/dev/null | sed 's/^/# /' >> "$TEMP_FILE"
        else
            echo "# Clean working directory" >> "$TEMP_FILE"
        fi
        
        # Branch and tracking info
        echo "#" >> "$TEMP_FILE"
        echo "# Branch information:" >> "$TEMP_FILE"
        if git status -b --porcelain 2>/dev/null | head -1; then
            git status -b --porcelain 2>/dev/null | head -1 | sed 's/^/# /' >> "$TEMP_FILE"
        else
            echo "# No branch information available" >> "$TEMP_FILE"
        fi
        
        # Replace the original file
        mv "$TEMP_FILE" "$COMMIT_MSG_FILE"
    fi
''
