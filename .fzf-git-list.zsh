# fzf:https://github.com/junegunn/fzf
# ripgrep:https://github.com/BurntSushi/ripgrep
# gnu-sed:https://www.gnu.org/software/sed/
function fzf_git_list()
{
	local branch
	
	branch=$(git branch --all | rg -v HEAD | fzf +m) &&
	git switch $(echo "$branch" | awk '{print $NF}' | sed 's#remotes/[^/]*/##') > /dev/null 2>&1
}
