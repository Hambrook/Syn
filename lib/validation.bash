# Library file for Syn


# Require two environments
function syn_validate_allow() {
	# Check if we're pushing to a live environment
	local to=$dst || $src

	# Check if we're pushing to a disallowed environment
	if [[ "${config[${to}/_allow]}" == false ]]; then
		syn_error "Pushing to this environment is not allowed"
		exit
	fi

	if [[ $to =~ (live|prod) || "${config[${to}/_allow]}" == "warn" ]]; then
		if ${flags[force]}; then
			syn_cli_info "WARNING: Forcing override of dangerous deployment warning"
			#printf "$(_ bg_yellow)\n\tWARNING: Forcing override of dangerous deployment warning\n$(_ reset)\n"
			#printf "$(_ yellow bold)WARNING: Forcing override of dangerous deployment warning$(_ reset)\n"
		elif ! syn_cli_confirm "Pushing to this environment could be dangerous, are you sure?" false; then
			printf "Aborting\n"
			exit
		fi
		printf "\n"
	fi
}


# Require one environment
function syn_validate_require_one_env() {
	# Is the environment set?
	if [[ ! "$src" ]]; then
		syn_error "You must specify an environment"
	fi
	# Is the environment valid?
	if [[ ! "${environments[$src]}" ]]; then
		syn_error "Environment '${src}' doesn't exist"
	fi
}


# Require two environments
function syn_validate_require_two_envs() {
	# Are both environments set?
	if [[ ! ( "$src" && "$dst" ) ]]; then
		syn_error "You must specify two environments"
	fi
	# Is the src environment valid?
	if [[ ! "${environments[$src]}" ]]; then
		syn_error "Source environment '$src' doesn't exist"
	fi
	# Is the dst environment valid?
	if [[ ! "${environments[$dst]}" ]]; then
		syn_error "Destination environment '$dst' doesn't exist"
	fi
	if [[ "$src" == "$dst" ]]; then
		syn_error "Souce and destination environments cannot be the same"
	fi
}
