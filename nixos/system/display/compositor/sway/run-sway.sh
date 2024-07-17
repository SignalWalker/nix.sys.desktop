#!/usr/bin/env sh

session_vars_file="/etc/profiles/per-user/$(whoami)/etc/profile.d/hm-session-vars.sh"
if [[ -f $session_vars_file ]]; then
	. $session_vars_file
fi

exec systemd-cat --identifier=sway sway $EXTRA_SWAY_ARGS
