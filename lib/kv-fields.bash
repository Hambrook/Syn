# Library file for Syn


# Get a filtered key/value array from a key/value field
# syn_kv_field_to_filtered_kv_array result_arr "local/after/src"
function syn_kv_field_to_filtered_kv_array() {
	local -n arr="${1}"      # return var name passed by reference (no $ on calling line)
	local config_key="${2}"  # config key, eg "live/after/dst"
	local only="${3}"        # filter: eg "mysite,themes". "*" = ALL lines, "" = DEFAULT lines (without ! prefix)
	local show_prefix=$4     # leave ! prefix on keys?
	local cnt=0
	local filter=""

	IFS=$'\n' read -rd '' -a lines <<<"${config[${config_key}]}"
	local pattern="^\s*(\!?)([^= ]*)(=?)(.*)"
	#if [[ ! -z $only && ! $only == "*" ]]; then
	#	pattern="^\s*(\!?)(${only//,/|})(=)(.*)"
	#fi
	# Filter using array instead of pattern so we can filter unnamed lines
	if [[ ! $only == "*" ]]; then
		filter=${only//,/ }
	fi
	for line in "${lines[@]}"; do
		if [[ $line =~ $pattern ]]; then
			# Remove non-defaults unless we want ALL
			if [[ "${BASH_REMATCH[1]}" && -z $only ]]; then
				continue
			fi
			k="${BASH_REMATCH[2]}"
			v="${BASH_REMATCH[4]}"
			# Is this row unnamed?
			if [[ -z ${BASH_REMATCH[3]} ]]; then
			(( cnt++ ))
				k="unnamed-${cnt}"
				v="${BASH_REMATCH[2]}"
			fi

			# Do filtering here so we can filter unnamed lines
			if [[ $filter ]] && ! in_array $k filter; then
				continue
			fi

			# Are we leaving the prefix on?
			if [[ $show_prefix ]]; then
				k="${BASH_REMATCH[1]}$k"
			fi
			: ${arr[${k}]:=${v}}
		fi
	done
}


# Get a filtered keys array from a key/value field
# syn_kv_field_to_filtered_k_array result_arr "local/after/src"
function syn_kv_field_to_filtered_k_array() {
	local -n arr="${1}"
	local config_key="${2}"
	local only="${3}"
	local show_prefix="${4}"
	local -A tmp

	syn_kv_field_to_filtered_kv_array tmp "${config_key}" "${only}" "${show_prefix}"

	arr=( "${!tmp[@]}" )
}


# Output kv field as list
function syn_list_kv_field() {
	local title="${1}"
	local config_key="${2}"
	local -A tmp

	syn_kv_field_to_filtered_kv_array tmp "${config_key}" "*" true
	printf "\n$(_ bold)%s$(_ reset)\n" "${title}"
	for k in "${!tmp[@]}"; do
		printf "  %s=%s\n" "${k}" "${tmp[$k]}"
	done
	if (( ${#tmp[@]} == 0 )); then
		printf "  <none>\n"
	fi
}
