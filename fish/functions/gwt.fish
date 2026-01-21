# git worktree (change directory)
function gwt
    set current_root (git rev-parse --show-toplevel 2>/dev/null)
    or return 1

    set relative_path (string replace "$current_root" "" (pwd))
    set selected (git worktree list | grep -v "^$current_root " | fzf --reverse --height 20)
    or return 0

    set target_root (echo $selected | awk '{print $1}')
    set target_path "$target_root$relative_path"

    if test -d "$target_path"
        cd "$target_path"
    else
        cd "$target_root"
    end
end
