# Library file for Syn


# Wrap SSH commands
function syn_ssh_wrap() {
	# $1 = SSH string
	# $2 = command
	printf "ssh %s %s" "$1" "$2"
}


# Wrap Docker commands
function syn_docker_wrap() {
	# $1 = docker container
	# $2 = command
	# $3 = additional flags
	printf "docker exec %s %s %s" "$3" "$1" "$2"
}
