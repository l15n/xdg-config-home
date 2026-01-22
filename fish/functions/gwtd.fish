# git worktree delete (remove worktree)
function gwtd
    set current_root (git rev-parse --show-toplevel 2>/dev/null)
    or return 1

    # Get main worktree (first in list)
    set main_root (git worktree list | head -1 | awk '{print $1}')

    # Build worktree list for fzf, find current index for default selection
    set worktrees (git worktree list)
    set current_index 1
    set i 1
    for wt in $worktrees
        set wt_path (echo $wt | awk '{print $1}')
        if test "$wt_path" = "$current_root"
            set current_index $i
        end
        set i (math $i + 1)
    end

    set selected (printf '%s\n' $worktrees | fzf --reverse --height 20 --header "Select worktree to remove" --default-pos=$current_index)
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
