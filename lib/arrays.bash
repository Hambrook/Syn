# Library file for Syn


# In Array (key exists?)
function in_array() {
	local haystack=${2}[@]
	local needle=${1}
	for i in ${!haystack}; do
		if [[ ${i} == ${needle} ]]; then
			return 0
		fi
	done
	return 1
}


# Alternate version
function in_array_string() {
	local haystack="$2"
	if [[ ! "$(declare -p haystack)" =~ "declare -a" ]]; then
		haystack=($haystack)
	fi
	local needle=$1
	local in=1
	for element in "${haystack[@]}"; do
		echo $element
		if [[ $element == "$needle" ]]; then
			in=0
			break
		fi
	done
	return $in
}


# Check if a function exists
function function_exists() {
	declare -f -F $1 > /dev/null
	return $?
}


# Check if an array key exists
function array_key_exists() {
	eval '[ ${'$2'[$1]+muahaha} ]'
}


# Join array elements together
function join() {
	local IFS="$1"; shift; echo "$*"
}


# Get a filtered key/value array from a key/value field
# array_to_filtered_array result_arr input_arr
function array_to_filtered_array() {
	local -n arr="${1}"      # return var name passed by reference (no $ on calling line)
	local -n haystack=${2}   # haystack to filter
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
	for k in "${!haystack[@]}"; do
		local v="$k"
		if [[ $only = "*" ]] || \
			[[ "${haystack[$k]}" && $only = "!" ]] || \
			[[ -z "${haystack[$k]}" && -z $only ]] || \
			( [[ $filter_only ]] && in_array $k filter_only ) || \
			( [[ $filter_plus ]] && in_array $k filter_plus ) \
		; then
			# Are we leaving the prefix on?
			if [[ $show_prefix ]]; then
				v="${haystack[$k]}$v"
			fi
			: ${arr[${k}]:=${v}}
		fi
	done
}
