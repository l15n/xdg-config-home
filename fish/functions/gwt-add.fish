# git worktree add (create new worktree with branch)
function gwt-add
    set branch_name $argv[1]
    if test -z "$branch_name"
        echo "Usage: gwta <branch-name>"
        return 1
    end

    # Get repo name from origin URL (works for https and ssh, with or without .git)
    set repo_name (basename (git remote get-url origin 2>/dev/null) .git)
    or return 1

    # Get directory name (part after last slash, or full name if no slash)
    set dir_name (string split -r -m1 '/' $branch_name)[-1]

    # Build worktree path: ../<repo>-worktrees/<dir>
    set worktree_base (dirname (git rev-parse --show-toplevel))
    set worktree_path "$worktree_base/$repo_name-worktrees/$dir_name"

    # Create worktree with new branch based on current HEAD
    git worktree add -b $branch_name $worktree_path
    and cd $worktree_path
end
