# Library file for Syn


# Config file autocomplete
function syn_var_config_autocomplete() {
	if [[ "${SYN_DEFAULT_PATH}" ]]; then
		ls ${SYN_DEFAULT_PATH}/*.syn | sed -e 's/.*\///' | sed -e 's/\..*$//'
	fi
}


# Config file loading
function syn_load_configs() {
	config_cnt=0

	# Paths
	local paths=()
	# Default
	if [[ "${SYN_DEFAULT_PATH}" ]]; then
		paths[${#paths[@]}]="${SYN_DEFAULT_PATH}"
	fi
	# Hierarchy
	local currpath="${PWD}"
	while [[ "${currpath}" != "/" ]]; do
		#paths[${#paths[@]}]="${currpath}"
		paths+=("${currpath}")
		currpath=$(cd "${currpath}/.." && pwd) || syn_error "Invalid path"
	done

	for pathname in "${paths[@]}"; do
		for filename in ".syn.global" ".syn" ".syn.local"; do
			if [[ -r "${pathname}/${filename}" ]]; then
				if [[ -z "${local_root}" && "${pathname}" != "${SYN_DEFAULT_PATH}" && -r "${pathname}/${filename}" ]]; then
					local_root="${pathname}"
				fi

				config_files+=("${pathname}/${filename}")
				if ${flags[debug]}; then
					printf "Loading config file: %s\n" "${pathname}/${filename}"
				fi
				. "${pathname}/${filename}"
				(( config_cnt++ ))
			fi
		done
	done
}


# Load specific config file (from --config parameter)
function syn_load_config_specific() {
	local var_config="${vars[config]}"
	local old_count=$config_cnt
	if [[ -d "${default_config_dir}" && "${var_config}" == "." ]]; then
		# If there is a default location and "." was set as file
		# then we'll use the current directory name as the filename
		# and only check the default location for the config file.
		vars[config]="${default_config_dir}/$(pwd | sed -e 's/.*\///g')"
		var_config="${vars[config]}"
		for f in "${var_config}.syn.global" "${var_config}" "${var_config}.syn" "${var_config}.syn.local"; do
			if [[ -f "$f" ]]; then
				config_files="${config_files}\n${f}"
				if ${flags[debug]}; then
					printf "Loading config file: %s\n" "$f"
				fi
				. "$f"
				(( config_cnt++ ))
			fi
		done
	elif [[ "${var_config}" ]]; then
		for f in "${var_config}.syn.global" "${var_config}" "${var_config}.syn" "${var_config}.syn.local"; do
			if [[ -f "$f" ]]; then
				# Otherwise we'll check the current dir for the named file
				config_files="${config_files}\n${f}"
				if ${flags[debug]}; then
					printf "Loading config file: %s\n" "$f"
				fi
				. "$f"
				(( config_cnt++ ))
			elif [[ -d "${default_config_dir}" && -f "${default_config_dir}/${f}" ]]; then
				# And the default location too
				config_files="${config_files}\n${default_config_dir}/${f}"
				if ${flags[debug]}; then
					printf "Loading config file: %s\n" "${default_config_dir}/${f}"
				fi
				. "${default_config_dir}/${f}"
				(( config_cnt++ ))
			fi
		done
	fi

	if [[ "${var_config}" ]] && (( "$old_count" == "$config_cnt" )); then
		local err=""
		if [[ -z "${SYN_DEFAULT_PATH}" ]]; then
			err=". Also, SYN_DEFAULT_PATH is not set."
		elif [[ ! -d "${SYN_DEFAULT_PATH}" ]]; then
			err=". Also, SYN_DEFAULT_PATH (${SYN_DEFAULT_PATH}) is not valid."
		fi
		syn_error "Could not find specific config file (${var_config})${err}"
	fi
}

