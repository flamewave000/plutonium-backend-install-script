#!/bin/bash
confirm() {
	local prompt default reply
	while true; do
		if [ "${2:-}" = "Y" ]; then
			prompt="Y/n"
			default=Y
		elif [ "${2:-}" = "N" ]; then
			prompt="y/N"
			default=N
		else
			prompt="y/n"
			default=
		fi
		# Ask the question (not using "read -p" as it uses stderr not stdout)
		printf "$1 [$prompt] "
		# Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
		read reply </dev/tty
		# Default?
		if [ -z "$reply" ]; then
			reply=$default
		fi
		# Check if the reply is valid
		case "$reply" in
			Y*|y*) return 0 ;;
			N*|n*) return 1 ;;
		esac
	done
}

if [ $# -ne 2 ]; then
	echo "How to use this script"
	echo " > $0 <foundry_dir> <data_dir>"
	echo ""
	echo "    <foundry_dir>  Installation directory of FoundryVTT"
	echo "    <data_dir>     FoundryVTT Data directory"
	exit
fi

fvtt="$1"
data="$2"
main="$fvtt/resources/app/main.mjs"
back="$fvtt/resources/app/main.mjs.plutonium-bak"
temp="$data/.main.mjs.tail.tmp"

if [ ! -e "$main" ]; then
	echo "$fvtt does not appear to be a correct FoundryVTT Installation directory"
	exit
fi
if [ ! -e "$data/Data/modules" ]; then
	echo "$data does not appear to be a correct FoundryVTT Data directory"
	exit
fi
if [ ! -e "$data/Data/modules/plutonium" ]; then
	echo "Cannot find Plutonium installation. Please install the Plutonium module before running this script."
	exit
fi

reverse() {
	echo -n "Reversing patches..."
	if [ -e "$fvtt/resources/app/plutonium-backend.mjs" ]; then
		rm -vf "$fvtt/resources/app/plutonium-backend.mjs"
	fi
	if [ -e "$back" ]; then
		if [ -e "$main" ]; then
			rm -vf "$main"
		fi
		mv -vf "$back" "$main"
	fi
	if [ -e "$temp" ]; then
		rm -vf "$temp"
	fi
	echo "done."
	return 1
}

if [[ -e "$back" ]]; then
	echo "Plutonium Backend Already Installed!"
	if confirm "Do you wish to uninstall it?" N; then
		reverse
	fi
	exit
fi

echo "Plutonium Backend Installation"
echo ""
echo "Which version of FoundryVTT do you have?"

select version in `/bin/ls $data/Data/modules/plutonium/server` "cancel"
do
	if [[ "$version" == "cancel" ]]; then
		echo "Cancelled"
		break
	fi
	echo -n "Copying backend script to installation..."
	cp -av "$data/Data/modules/plutonium/server/$version/plutonium-backend.mjs" "$fvtt/resources/app/"
	echo "done."
	echo -n "Making backup of FoundryVTT file..."
	mv -vf "$main" "$back"
	echo "done."
	echo -n "Patching FoundryVTT file..."
	# Get the line count of the file
	# NOTE: wc -l output is different between Linux & FreeBSD -- employing bash subshell interpolation to work around
	lines=( $(wc -l "$back" || reverse || exit) )
	# Get the line number of the init call
	top=`grep -n "init.default({" "$back" | cut -d: -f1 || reverse || exit`
	# Write the top portion of the file to main.mjs
	head -$((top - 1)) "$back" > "$main" || reverse || exit
	# Write the new awaited invocation of init
	echo "  await init.default({" >> "$main" || reverse || exit
	# Copy the bottom portion of the file to a temp
	tail -$((lines - top)) "$back" > "$temp" || reverse || exit
	# get the line count of that temp file
	# NOTE: wc -l output is different between Linux & FreeBSD -- employing bash subshell interpolation to work around
	lines=( $(wc -l "$temp" || reverse || exit) )
	# Get the line number of the function closure
	bot=`grep -n "})();" "$temp" | cut -d: -f1 || reverse || exit`
	# Output the middle content of the file
	head -$((bot - 2)) "$temp" >> "$main" || reverse || exit
	echo "  });" >> "$main" || reverse || exit
	# Output the Plutonium Import
	echo "  (await import(\"./plutonium-backend.mjs\")).Plutonium.init();" >> "$main" || reverse || exit
	# Output the bottom portion of the file
	tail -$((lines - $((bot - 1)))) "$temp" >> "$main" || reverse || exit
	# Copy/restore ownership of main
	lsl=( $(ls -l "$back") )
	owner="${lsl[2]}"
	group="${lsl[3]}"
	chown ${owner}:${group} $main
	# Remove the temporary file
	rm "$temp"
	echo "done."
	echo "Installation Complete!"
	exit
done


