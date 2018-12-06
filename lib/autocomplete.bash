# Library file for Syn


# Autocomplete (yeah it shouldn't be here, I'll find somewhere better for it)
function syn_var_only_autocomplete() {
	declare -a allactions
	local envmatch="[^/]+"
	# Limit to actions for the specified environments
	if [[ $src ]]; then
		envmatch="${src}"
		if [[ $dst ]]; then
			envmatch="${envmatch}|${dst}"
		fi
	fi
	local pattern="^(${envmatch})/(\!?)([^_][^/]+)"
	for p in "${!config[@]}"; do
		if [[ $p =~ $pattern ]]; then
			allactions+=( "${BASH_REMATCH[3]}" )
		fi
	done
	syn_autocomplete_array_field allactions "${1}"
}


# also shouldn't be here
function syn_var_plus_autocomplete() {
	declare -a nondefaultactions
	local pattern="^[^/]+/\!([^_][^/]+)"
	for p in "${!config[@]}"; do
		if [[ $p =~ $pattern ]]; then
			nondefaultactions+=( "${BASH_REMATCH[1]}" )
		fi
	done
	syn_autocomplete_array_field nondefaultactions "${1}"
}


# Generate autocomplete results for CLI if needed
function syn_check_autocomplete_request() {
	if [[ $autocomplete == false ]]; then
		return
	fi

	local current="${vars[autocomplete-current]}"
	local previous="${vars[autocomplete-previous]}"

	# Suggest values for the current --var
	if [[ "${previous}" ]]; then
		for v in "${!vars[@]}"; do
			if [[ "${previous}" == "--${v}" ]]; then
				# syn_var_after-only_complete
				local f="syn_var_${v}_autocomplete"
				if function_exists "${f}"; then
					eval "${f}" "${current}"
				fi
				exit
			fi
		done
	fi

	# Print environments if they're not already set
	if [[ -z $dst ]]; then
		printf "%s " "${environments[@]}"
	fi

	# todo: Remove flags/commands/vars that are already part of the command
	printf "\-\-%s " "${!flags_help[@]}"
	printf "\-\-%s " "${!commands[@]}"
	printf "\-\-%s " "${!vars_help[@]}"

	exit
}


# Autocomplete for vars
function syn_autocomplete_kv_field() {
	local config_key="${1}"
	local current="${2}"
	local all_or_nondefault="${3:-"*"}"
	declare -a valid_existing
	declare -a suggestions

	# Get all valid keys
	syn_kv_field_to_filtered_k_array valid_suggestions "${config_key}" "*"
	syn_kv_field_to_filtered_k_array suggestions "${config_key}" "${all_or_nondefault}"

	# Get keys already entered on the CLI unless partial or invalid
	IFS=$',' read -rd '' -a existing <<<"${current}"
	for linekey in "${existing[@]}"; do
		if in_array "${linekey}" valid_suggestions; then
			valid_existing+=("${linekey}")
		fi
	done

	prefix=$(join "," "${valid_existing[@]}")
	for k in "${!suggestions[@]}"; do
		if [[ "${#valid_existing[@]}" == 0 ]]; then
			echo "${suggestions[${k}]}"
		elif ! in_array "${suggestions[${k}]}" existing; then
			echo "${prefix},${suggestions[${k}]}"
		fi
	done
}


# Autocomplete for vars
function syn_autocomplete_array_field() {
	local -n available="${1}"      # var name passed by reference (no $ on calling line)
	local current="${2}"           # current value (eg rsync,mysql)
	declare -a valid_existing

	# Get keys already entered on the CLI unless partial or invalid
	IFS=$',' read -rd '' -a existing <<<"${current}"
	for linekey in "${existing[@]}"; do
		if in_array "${linekey}" available; then
			valid_existing+=("${linekey}")
		fi
	done

	prefix=$(join "," "${valid_existing[@]}")
	for k in "${!available[@]}"; do
		if [[ "${#valid_existing[@]}" == 0 ]]; then
			echo "${available[${k}]}"
		elif ! in_array "${available[${k}]}" existing; then
			echo "${prefix},${available[${k}]}"
		fi
	done
}
