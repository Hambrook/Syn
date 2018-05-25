# Library file for Syn


# In Array
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
