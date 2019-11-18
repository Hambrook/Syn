# Library file for Syn


function syn_cmd_notifications() {
	local param=$src || $dst
	if [[ $param == "test" ]]; then
		syn_notifications_show "Test Title" "Text text here (more info)" "${icon}/assets/icon.png" "transfer.complete"
		exit
	fi

	syn_cli_render_title "Notifications:"


	if syn_notifications_has_notifysend; then
		printf "  Enabled via notifiy-send\n\n"
	elif syn_notifications_has_burnttoast; then
		printf "  Enabled via BurntToast\n\n"
	elif syn_notifications_has_powershell; then
		syn_notifications_burnttoast_install_help
	fi
	printf "  Test using: syn --notifications test\n\n"
}
function syn_cmd_notifications_help() {
	printf "Show available notification options or test"
}

function syn_notifications_show() {
	local title="$1"
	local text="$2"
	local icon="$3"
	local category="$4"



	# Popup notification
	if syn_notifications_has_notifysend; then
		notify-send \
			--category="${category}" \
			--icon="${icon}/assets/icon.png" \
			"${title}" \
			"${text}"
	# If in WSL then try showing notification via BurntToast
	elif syn_notifications_has_burnttoast; then
		powershell.exe -command New-BurntToastNotification \
		-Text \"$title\", \"$text\" \
		&> /dev/null
	fi
}

# Test if notify-send is available (most Linux desktops)
function syn_notifications_has_notifysend() {
	if which notify-send > /dev/null; then
		return 0
	fi
	return 1
}

# Test if PowerShell is available (via WSL on Win10)
function syn_notifications_has_powershell() {
	if which powershell.exe > /dev/null; then
		return 0
	fi
	return 1
}

# Test if the user has already installed BurntToast (via PowerShell on Win10)
function syn_notifications_has_burnttoast() {
	if syn_notifications_has_powershell; then
		local tmp=$(powershell.exe -command Get-Module -ListAvailable -Name BurntToast2)
		if [ ! -z "${tmp}" ]; then
			return 0
		fi
	fi
	return 1
}

function syn_notifications_burnttoast_install_help() {
	printf "  Syn shows onscreen notifications when operations finish.\n"
	printf "  To enable this on WSL, run the below command as administrator in a PowerShell window.\n\n"
	printf "    Install-Module -Name BurntToast\n\n"
}
