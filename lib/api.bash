# Library file for Syn


# Would reference settings like this in the plugin files
#	api_versions[rsync]=2
# and this in config files
#	config[_api/rsync]=2

function syn_cmd_api-versions() {
	local param=$src || $dst
	local versioncolumn=""

	printf "If your config files are an older version than then API for each plugin, then you'll need to update them.\n"
	printf "You set the API version of your config files with the following line at the top of them:\n"
	printf "\n  config[api/<plugin-name>]=2\n"
	printf "\neg.\n"
	printf "\n  config[api/rsync]=2\n\n"

	syn_cli_render_title "Plugin API Versions"

	for plugin in ${plugins[*]}; do
		if [[ -z $param || $param == $plugin ]]; then
			: ${api_versions[$plugin]:=1}
			versioncolumn="API: v${api_versions[$plugin]} "

			#if [[ ! -z ${actions[$plugin]} ]]; then

			# detects plugins we're configured for even if we aren't using it this time
			if [[ ! -z ${config[_api/$plugin]} ]]; then
				: ${config[_api/$plugin]:=1}
				versioncolumn="${versioncolumn}  Config: v${config[_api/$plugin]}"
				if syn_api_version_check_raw $plugin; then
					versioncolumn="${versioncolumn}  $(_ green)[Up to date]$(_ reset)"
				else
					versioncolumn="${versioncolumn}  $(_ red)[NEEDS UPDATED]$(_ reset)"
				fi
			else
				versioncolumn="${versioncolumn}  (unused or not set)"
			fi

			syn_cli_render_kv_row $plugin "${versioncolumn}" "lightyellow"
		fi
	done

	if [[ -z $param ]]; then
		printf "\nTo see the API changes for a plugin, use:\n"
		printf "\n  syn --api-versions <plugin>\n"
	else
		printf "\n"
		if compgen -A function "syn_api_${param}" &> /dev/null; then
			eval "syn_api_${param}"
		fi
	fi
}
function syn_cmd_notifications_help() {
	printf "Show plugin API versions"
}

function syn_api_version_check() {
	local plugin="${1}"

	# Out of date
	if ! syn_api_version_check_raw $plugin; then
		syn_error "Your configuration for the \"$plugin\" plugin is out of date. See 'syn --api-versions' for more info"
	fi
}

function syn_api_version_check_raw() {
	local plugin="${1}"

	: ${api_versions[$plugin]:=1}
	: ${config[_api/$plugin]:=1}

	if [ "${config[_api/$plugin]}" -lt "${api_versions[$plugin]}" ]; then
		return 1
	else
		return 0
	fi
}
