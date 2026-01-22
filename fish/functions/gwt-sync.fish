# git worktree sync (sync target worktree state to main for testing)
function gwt-sync
    set current_root (git rev-parse --show-toplevel 2>/dev/null)
    or return 1

    # Get main worktree (first in list)
    set main_root (git worktree list | head -1 | awk '{print $1}')

    # Verify we're in the main worktree
    if test "$current_root" != "$main_root"
        echo "Error: Must run from main worktree ($main_root)"
        return 1
    end

    # Check main worktree is clean
    if test -n (git status --porcelain 2>/dev/null)
        echo "Error: Main worktree has uncommitted changes"
        echo "Please commit or stash changes before syncing"
        return 1
    end

    # Select target worktree (exclude main)
    set selected (git worktree list | grep -v "^$main_root " | fzf --reverse --height 20 --header "Select worktree to sync from")
    or return 0

    set target_root (echo $selected | awk '{print $1}')

    # Get target's HEAD commit
    set target_head (git -C "$target_root" rev-parse HEAD)
    set target_head_short (git -C "$target_root" rev-parse --short HEAD)

    # Get uncommitted files in target (staged + unstaged)
    set uncommitted_files (git -C "$target_root" diff HEAD --name-only)

    # Build confirmation message
    echo "Sync from: $target_root"
    echo "Will checkout: $target_head_short (detached HEAD)"
    if test (count $uncommitted_files) -gt 0
        echo "Uncommitted files to copy:"
        for file in $uncommitted_files
            # Get status indicator
            set status (git -C "$target_root" status --porcelain -- "$file" | string sub -l 2)
            echo "  $status $file"
        end
    else
        echo "No uncommitted files to copy"
    end

    read -P "Proceed? [y/N] " confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Cancelled"
        return 0
    end

    # Store current branch for restore
    set repo_name (basename "$main_root")
    set restore_file "/tmp/gwts-restore-$repo_name"
    set current_branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$current_branch"
        echo "Error: Not on a branch (already in detached HEAD?)"
        return 1
    end

    # Write restore info: branch name, then list of copied files
    echo $current_branch > $restore_file
    for file in $uncommitted_files
        echo $file >> $restore_file
    end

    # Checkout target HEAD (detached)
    git checkout $target_head
    or begin
        rm -f $restore_file
        return 1
    end

    # Copy uncommitted files from target to main
    for file in $uncommitted_files
        set src "$target_root/$file"
        set dst "$main_root/$file"
        # Create parent directory if needed
        mkdir -p (dirname "$dst")
        cp "$src" "$dst"
    end

    echo ""
    echo "Synced to $target_head_short from $target_root"
    echo "Run 'gwt-restore' to restore original state"
end
