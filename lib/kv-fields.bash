# Library file for Syn


# Get a filtered key/value array from a key/value field
# syn_kv_field_to_filtered_kv_array result_arr "local/after/src"
function syn_kv_field_to_filtered_kv_array() {
	local -n arr="${1}"      # return var name passed by reference (no $ on calling line)
	local config_key="${2}"  # config key, eg "live/after/dst"
	local only="${3}"        # filter: eg "mysite,themes". "*" = ALL lines, "" = DEFAULT lines (without ! prefix)
	local plus="${4}"        # add items to default list (used when not using "only"
	local show_prefix=$5     # leave ! prefix on keys?
	local cnt=0
	local filter_only=""
	local filter_plus=${plus//,/ }

	# Filter using array instead of pattern so we can filter unnamed lines
	if [[ ! $only == "*" ]]; then
		filter_only=${only//,/ }
	fi

	IFS=$'\n' read -rd '' -a lines <<<"${config[${config_key}]}"
	local pattern="^\s*(\!?)([^= ]*)(=?)(.*)"
	#if [[ ! -z $only && ! $only == "*" ]]; then
	#	pattern="^\s*(\!?)(${only//,/|})(=)(.*)"
	#fi
	for line in "${lines[@]}"; do
		if [[ $line =~ $pattern ]]; then
			k="${BASH_REMATCH[2]}"
			v="${BASH_REMATCH[4]}"
			# Is this row unnamed?
			if [[ -z ${BASH_REMATCH[3]} ]]; then
				(( cnt++ ))
				k="unnamed-${cnt}"
				v="${BASH_REMATCH[2]}"
			fi

			# Do filtering here so we can filter unnamed lines

			# Remove defaults if we only want non-defaults
			if [[ -z "${BASH_REMATCH[1]}" && $only = "!" ]]; then
				continue
			fi

			if [[ $only = "*" ]] || \
				[[ ${BASH_REMATCH[1]} && $only = "!" ]] || \
				[[ -z ${BASH_REMATCH[1]} && -z $only ]] || \
				( [[ $filter_only ]] && in_array $k filter_only ) || \
				( [[ $filter_plus ]] && in_array $k filter_plus ) \
			; then
				# Are we leaving the prefix on?
				if [[ $show_prefix ]]; then
					k="${BASH_REMATCH[1]}$k"
				fi
				: ${arr[${k}]:=${v}}
			fi
		fi
	done
}


# Get a filtered keys array from a key/value field
# syn_kv_field_to_filtered_k_array result_arr "local/after/src"
function syn_kv_field_to_filtered_k_array() {
	local -n arr="${1}"
	local config_key="${2}"
	local only="${3}"
	local plus="${4}"
	local show_prefix="${5}"
	local -A tmp

	syn_kv_field_to_filtered_kv_array tmp "${config_key}" "${only}" "${plus}" "${show_prefix}"

	arr=( "${!tmp[@]}" )
}


# Output kv field as list
function syn_list_kv_field() {
	local title="${1}"
	local config_key="${2}"
	local -A tmp

	syn_kv_field_to_filtered_kv_array tmp "${config_key}" "*" "" true
	printf "\n$(_ bold)%s$(_ reset)\n" "${title}"
	for k in "${!tmp[@]}"; do
		printf "  %s=%s\n" "${k}" "${tmp[$k]}"
	done
	if (( ${#tmp[@]} == 0 )); then
		printf "  <none>\n"
	fi
}
