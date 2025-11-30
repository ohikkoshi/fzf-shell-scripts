#!/bin/bash
# shellcheck disable=SC2016,SC2155
#
# @fzf https://github.com/junegunn/fzf
# @ripgrep https://github.com/BurntSushi/ripgrep
# @gnu-sed https://www.gnu.org/software/sed/
fzf_git_switch() {
	local tmp1="/tmp/fzf_git_lb_$$"
	local tmp2="/tmp/fzf_git_rb_$$"
	local tmp3="/tmp/fzf_git_lt_$$"
	trap 'rm -f "$tmp1" "$tmp2" "$tmp3" 2>/dev/null' EXIT

	# git branch
	git branch --format='%(refname:short)' >"$tmp1" &
	git branch -r 2>/dev/null | rg -v 'HEAD' | awk '{print $NF}' >"$tmp2" &
	git tag --list >"$tmp3" &
	wait

	local local_branches=$(cat "$tmp1")
	local remote_branches=$(cat "$tmp2")
	local local_tags=$(sed 's/^/tags\//' "$tmp3")
	local remote_tags=""

	# support for remote tags
	#remote_tags=$(
	#	git ls-remote --tags origin 2>/dev/null |
	#	awk '$2 !~ /\^{}$/ {sub("refs/tags/", "", $2); print $2}' |
	#	sort -u |
	#	comm -13 <(sort "$tmp3") - 2>/dev/null |
	#	sed 's/^/origin\/tags\//'
	#)

	# fzf
	local selection=$(
		printf "%s\n%s\n%s\n%s" \
			"$local_branches" "$remote_branches" "$local_tags" "$remote_tags" |
			rg -v '^$' |
			fzf +m
	)

	# cancel
	rm -f "$tmp1" "$tmp2" "$tmp3" 2>/dev/null
	[[ -z "$selection" ]] && return 0

	# git switch
	case "$selection" in
	tags/* | origin/tags/*)
		local tag_name="${selection#tags/}"
		tag_name="${tag_name#origin/}"

		local new_branch="feature/$tag_name"
		echo "tags/$tag_name → $new_branch"

		if git show-ref --quiet "refs/heads/$new_branch"; then
			git switch "$new_branch"
		else
			git switch -c "$new_branch" "$tag_name"
		fi
		;;
	origin/* | */*)
		local branch="${selection#*/}"
		git switch "$branch" 2>/dev/null ||
			git switch -c "$branch" --track "$selection"
		;;
	*)
		git switch "$selection"
		;;
	esac
}
