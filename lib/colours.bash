# Library file for Syn


# Formatting vars
formatting=(
	# Formatting
	[normal]=0
	[reset]=0
	[bold]=1
	[dim]=2
	[underline]=4
	[ul]=4
	[blink]=5
	[reverse]=7
	[hidden]=8
	# Reset formatting
	[r_bold]=22 # should be 21 but it's not widely supported: https://stackoverflow.com/questions/15579739/in-an-xterm-can-i-turn-off-bold-or-underline-without-resetting-the-current-colo#comment72979164_15581497
	[r_dim]=22
	[r_underline]=24
	[r_ul]=24
	[r_blink]=25
	[r_reverse]=27
	[r_hidden]=28
	# Foreground colours
	[default]=39
	[black]=30
	[red]=31
	[green]=32
	[yellow]=33
	[blue]=34
	[magenta]=35
	[cyan]=36
	[lightgray]=37
	[darkgray]=90
	[lightred]=91
	[lightgreen]=92
	[lightyellow]=93
	[lightblue]=94
	[lightmagenta]=95
	[lightcyan]=96
	[white]=97
	# Background colours
	[bg_default]=49
	[bg_black]=40
	[bg_red]=41
	[bg_green]=42
	[bg_yellow]=43
	[bg_blue]=44
	[bg_magenta]=45
	[bg_cyan]=46
	[bg_lightgray]=47
	[bg_darkgray]=100
	[bg_lightred]=101
	[bg_lightgreen]=102
	[bg_lightyellow]=103
	[bg_lightblue]=104
	[bg_lightmagenta]=105
	[bg_lightcyan]=106
	[bg_white]=107
)


# Get a formatting string
function _() {
	if [[ ! $# || $colour_enabled == false ]]; then
		return
	fi

	output=""
	for var in "$@"; do
		if array_key_exists $var formatting; then
			if [[ $output != "" ]]; then
				output="${output};"
			fi
			output="${output}${formatting[${var}]}"
		fi
	done

	printf "\e[${output}m"
}
function syn_cmd_colours() {
	syn_cli_render_title "Colours Preview:"
	printf "  %-18s %s\n" "Normal" "Bold"
	for v in default black red green yellow blue magenta cyan lightgray darkgray lightred lightgreen lightyellow lightblue lightmagenta lightcyan white; do
		printf "  $(_ $v)%-18s$(_ bold) %s$(_ reset)\n" "$v" "$v"
	done
	exit
}
function syn_cmd_colours_help() {
	echo "help"
}
