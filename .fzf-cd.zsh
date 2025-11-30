# fzf:https://github.com/junegunn/fzf
# eza:https://github.com/eza-community/eza
# gnu-sed:https://www.gnu.org/software/sed/
function cd()
{
	if [[ "$#" != 0 ]]; then
		builtin cd "$@";
		return
	fi

	local directories
	local dir

	while true; do
		directories=$(echo ".." && find . -maxdepth 1 ! -path . -type d -o -type l | sed 's|^\./||' | sort)
		dir="$(
			printf '%s\n' "${directories[@]}" |
			fzf --preview '
				__cd_nxt="$(echo {})";
				__cd_path="$(realpath -s "$(pwd)/${__cd_nxt}" 2>/dev/null || echo "$(pwd)/${__cd_nxt}")";
				echo $__cd_path;
				echo;
				eza -1aF --no-quotes --color=always --icons=auto --group-directories-first "${__cd_path}";
			')"

		[[ ${#dir} != 0 ]] || return 0

		builtin cd "$dir" &> /dev/null
	done
}
