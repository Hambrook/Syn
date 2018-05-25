# Library file for Syn


function syn_render_help_commands() {
	printf "$(_ bold)Commands:$(_ r_bold)\n"
	for c in ${!commands[*]}; do
		printf "  --%-16s %s\n" "$c" "$(${commands[$c]})"
	done
}


function syn_render_help_flags() {
	printf "$(_ bold)Flags:$(_ r_bold)\n"
	for f in ${!flags_help[*]}; do
		printf "  --%-16s %s\n" "$f" "${flags_help[$f]}"
	done
}


function syn_render_help_vars() {
	printf "$(_ bold)Vars:$(_ r_bold)\n"
	for v in ${!vars_help[*]}; do
		printf "  --%-16s %s\n" "$v" "${vars_help[$v]}"
	done
}


# Help. Will show specific help from a plugin, or general help with
# lists of environments and plugins
function syn_cmd_help() {
	syn_banner
	if [[ "$1" ]]; then
		if [[ $(set | grep "syn_plugin_${1}_help ()") ]]; then
			printf "Showing help for plugin: %s\n\n" "$1"
			eval "syn_plugin_${1}_help"
			exit
		else
			syn_error "Plugin '$1' not found"
		fi
	fi

	printf "
A pluggable system to synchronise between environments with builtin plugins
for mysql and rsync.

Usage: syn <SRC> <DST> [COMMANDS/FLAGS/VARS]

$(_ bold)Parameters:$(_ r_bold)
  SRC                Must match an environment from the loaded config files
  DST                Must match an environment from the loaded config files

$(syn_render_help_commands)

$(syn_render_help_flags)

$(syn_render_help_vars)

$(syn_cmd_envs)

$(syn_cmd_plugins)

$(syn_cmd_paths)

$(syn_cmd_configs)
"
# | less

	exit
}
function syn_cmd_help_help() {
	printf "Show this help (or append a plugin name for specific help)"
}


# Do we need to show the help?
function syn_check_help_request() {
	if [[ "$#" == 0 || "$cmd" == "help" || ( "$#" == 2 && "${vars[file]}" ) ]]; then
		syn_cmd_help $src || $dst
		exit
	fi
}
