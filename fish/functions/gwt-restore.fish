# git worktree sync restore (restore main worktree after testing)
function gwt-restore
    set current_root (git rev-parse --show-toplevel 2>/dev/null)
    or return 1

    # Get main worktree (first in list)
    set main_root (git worktree list | head -1 | awk '{print $1}')

    # Verify we're in the main worktree
    if test "$current_root" != "$main_root"
        echo "Error: Must run from main worktree ($main_root)"
        return 1
    end

    # Check for restore file
    set repo_name (basename "$main_root")
    set restore_file "/tmp/gwts-restore-$repo_name"

    if not test -f "$restore_file"
        echo "Error: No sync state found (missing $restore_file)"
        echo "Run 'gwt-sync' first to sync from a worktree"
        return 1
    end

    # Verify we're in detached HEAD
    if git symbolic-ref HEAD >/dev/null 2>&1
        echo "Error: Not in detached HEAD state"
        echo "Expected to be in synced state from 'gwt-sync'"
        return 1
    end

    # Read restore info
    set restore_lines (cat $restore_file)
    set original_branch $restore_lines[1]
    set copied_files $restore_lines[2..-1]

    # Get current uncommitted changes
    set uncommitted_files (git diff HEAD --name-only)

    # Build confirmation message
    echo "Restore to branch: $original_branch"
    if test (count $uncommitted_files) -gt 0
        echo "Will discard uncommitted changes:"
        for file in $uncommitted_files
            set file_status (git status --porcelain -- "$file" | string sub -l 2)
            echo "  $file_status $file"
        end
    else
        echo "No uncommitted changes to discard"
    end

    read -P "Proceed? [y/N] " confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Cancelled"
        return 0
    end

    # Discard staged/modified changes
    git checkout HEAD -- .

    # Remove untracked files that were copied during sync
    for file in $copied_files
        set filepath "$main_root/$file"
        # Only remove if it exists and is untracked
        if test -f "$filepath"
            if git ls-files --error-unmatch "$file" >/dev/null 2>&1
                # File is tracked, already handled by checkout
                :
            else
                # File is untracked, remove it
                rm -f "$filepath"
            end
        end
    end

    # Checkout original branch
    git checkout $original_branch
    or begin
        echo "Error: Failed to checkout $original_branch"
        return 1
    end

    # Clean up restore file
    rm -f $restore_file

    echo ""
    echo "Restored to branch: $original_branch"
end
