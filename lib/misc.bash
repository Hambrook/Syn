# Library file for Syn


# Exit with an error and a non-successful exit code
function syn_error() {
	local error="${1:-"An unknown error has occured"}"
	printf "$(_ red)Error: %s\n" "${error}$(_ reset)" 1>&2
	exit 1
}


# Show a prompt for confirmation
function syn_confirm() {
	# $1 = Question
	# $2 = default (y/true/n/false)

	local prompt="y/N"
	local default=1
	if [[ $2 =~ ^[Yy].* ]]; then
		prompt="Y/n"
		default=0
	fi

	read -p "$(_ yellow)${1} [${prompt}]:$(_ reset) " response

	if [[ $response =~ ^[Yy].* ]]; then
		return 0
	fi
	if [[ $response = "" ]]; then
		return $default
	fi
	return 1
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
