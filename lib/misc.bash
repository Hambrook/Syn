# Library file for Syn


# Exit with an error and a non-successful exit code
function syn_error() {
	local error="${1:-"An unknown error has occured"}"
	printf "$(_ bold red)⚠$(_ r_bold) Error: %s\n" "${error}$(_ reset)" 1>&2
	exit 1
}


# Check if a plugin exists
function syn_validate_plugin() {
	if [[ $(set | grep "syn_plugin_$1 ()") ]]; then
		echo 1
	else
		echo ""
	fi
}


# Get the actual plugin name from a potentially aliased (fuzzy) name... eg. rsync.webdirs
function syn_get_plugin_name_from_fuzzy() {
	printf "$1" | sed -e 's/[(\.].*//g'
}
