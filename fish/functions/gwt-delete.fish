# git worktree delete (remove worktree)
function gwt-delete
    set current_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "Error: Not in a git repository"
        return 1
    end

    # Get main worktree (first in list) and linked worktrees
    set main_root (git worktree list | head -1 | awk '{print $1}')
    set linked_worktrees (git worktree list | tail -n +2)

    if test (count $linked_worktrees) -eq 0
        echo "No linked worktrees to remove"
        return 0
    end

    set selected (printf '%s\n' $linked_worktrees | fzf --reverse --height 20 --header "Select worktree to remove")
    or return 0

    set target_root (echo $selected | awk '{print $1}')

    # Confirm removal
    echo "Remove worktree: $target_root"
    read -P "Are you sure? [y/N] " confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Cancelled"
        return 0
    end

    # If removing current worktree, switch to main first
    if test "$target_root" = "$current_root"
        cd "$main_root"
    end

    git worktree remove $target_root
    and echo "Removed worktree: $target_root"

    # Return to main worktree if not already there
    if test (git rev-parse --show-toplevel 2>/dev/null) != "$main_root"
        cd "$main_root"
    end
end
