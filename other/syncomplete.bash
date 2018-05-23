_syn_autocomplete() {
	local cur prev opts origCommand
	COMPREPLY=()
	origCommand="${COMP_WORDS[0]}"
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	unset COMP_WORDS[0]
	unset COMP_WORDS[COMP_CWORD]

	opts=$(${origCommand} __AUTOCOMPLETE__ --autocomplete-previous=${prev} --autocomplete-current=${cur} ${COMP_WORDS[@]})
	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	return 0
}

complete -F _syn_autocomplete syn
