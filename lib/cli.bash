# Library file for Syn


# Show a prompt for confirmation
function syn_cli_confirm() {
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


function syn_cli_render_title() {
	if [ "$1" ]; then
		printf "$(_ bold blue)$1$(_ r_bold default)\n"
	fi
}


function syn_cli_render_kv_row() {
	colour="$3"
	if [ ! "${colour}" ]; then
		colour="green"
	fi
	if [ "$1" ]; then
		if [ "$2" ]; then
			printf "  $(_ $colour)%-18s$(_ default) %s\n" "$1" "$2"
		else
			printf "  $(_ $colour)%s$(_ default) %s\n" "$1"
		fi
	fi
}
