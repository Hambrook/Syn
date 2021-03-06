# Library file for Syn


# List all or requested actions (eg --only rsync,after)
function syn_parse_actions() {
	local envmatch="[^/]+"
	# Limit to actions for the specified environments
	if [[ $src ]]; then
		envmatch="${src}"
		if [[ $dst ]]; then
			envmatch="${envmatch}|${dst}"
		fi
	fi

	# Need to sort by plugin exec order
	for p in "${plugins_exec[@]}"; do
		local pattern="^(${envmatch})/(\!?)(${p}[^/]*)/"
		for k in "${!config[@]}"; do
			if [[ $k =~ $pattern ]]; then
				: ${actions_all[${BASH_REMATCH[3]}]:=${BASH_REMATCH[2]}}
			fi
		done
	done

	array_to_filtered_array actions actions_all "${vars[only]}" "${vars[plus]}" 1
}


# Get the commands that have help text
function syn_parse_commands() {
	for c in $(compgen -A function syn_cmd_); do
		local cmd="${c//syn_cmd_/}"
		if [[ $c =~ ^syn_cmd_(.+?)_help$ ]]; then
			commands[${BASH_REMATCH[1]}]="$c"
		fi
	done
}


# Get configured environment names
function syn_parse_environments() {
	environments=""
	local pattern="^[^_][^/]+"
	for e in "${!config[@]}"; do
		if [[ $e =~ $pattern ]]; then
			: ${environments[$BASH_REMATCH]:=$BASH_REMATCH}
		fi
	done
}


# Parameter loading
function syn_parse_parameters() {
	if [[ $1 == "__AUTOCOMPLETE__" ]]; then
		autocomplete=true
		shift
	fi

	# Tried a switch statement, this more efficient
	for (( i=1; i<=$#; i++ )); do
		# Strip leading dashes and test for flags, commands and vars
		if [[ ${!i} =~ ^\-\-(.*) ]]; then
			# Is it a flag, eg "--dryrun"?
			if array_key_exists "${BASH_REMATCH[1]}" flags; then
				flags[${BASH_REMATCH[1]}]=true
			# Is it a command, eg "--help"?
			elif [[ $(type -t "syn_cmd_${BASH_REMATCH[1]}") == "function" ]]; then
				cmd="${BASH_REMATCH[1]}"
			# Is it a space-separated var, eg "--only rsync"?
			elif array_key_exists "${BASH_REMATCH[1]}" vars; then
				(( i++ ))
				vars[${BASH_REMATCH[1]}]="${!i}"
			# Or even an equals separated var, eg "--only=rsync"?
			elif [[ "${BASH_REMATCH[1]}" == *"="* ]]; then
				local varinfo=(${BASH_REMATCH[1]//=/ })
				if array_key_exists "${varinfo[0]}" vars; then
					vars[${varinfo[0]}]="${varinfo[1]}"
				fi
			fi
		# If there are no leading dashes then it must be an environment
		elif [[ ! ${!i} =~ ^- ]]; then
			if [[ ! "$src" ]]; then
				src="${!i}"
			elif [[ ! "$dst" ]]; then
				dst="${!i}"
			elif [[ $autocomplete == false ]]; then
				syn_error "Unrecognised parameter '${!i}'"
			fi
		elif [[ $autocomplete == false ]]; then
			syn_error "Unrecognised parameter '${!i}'"
		fi
	done
}


# Get the available plugins
function syn_parse_plugins() {
	plugins=()
	plugins_exec=()
	declare -A plugins_raw
	for p in $(compgen -A function syn_plugin_); do
		if [[ $p =~ _help$ ]]; then
			continue
		fi
		local plugin_name="${p//syn_plugin_/}"
		local plugin_key="${exec_order[${plugin_name}]}"
		if [[ ! "$plugin_key" ]]; then
			plugin_key=50
		fi
		plugins+=("${plugin_name}")
		plugin_key="${plugin_key}_${plugin_name}"
		plugins_raw[${plugin_key}]="${plugin_name}"
	done

	local indexes=(${!plugins_raw[@]})
	IFS=$'\n' sorted=($(sort <<<"${indexes[*]}"))
	unset IFS
	for k in "${sorted[@]}"; do
		plugins_exec+=("${plugins_raw[$k]}")
	done
}
