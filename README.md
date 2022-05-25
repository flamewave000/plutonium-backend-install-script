# Plutonium Backend Installer Script

This script is just a simple one that adds the Plutonium backend to your FoundryVTT installation.

This script currently only supports linux based installations. It is possible this script will also work on Apple Mac, but I do not own any Apple products and cannot test that.

## How to Use

1. Install the Plutonium module
2. Shutdown your FoundryVTT server
3. Run the following to make sure the script can be executed:  
	`> chmod +x plutonium-backend.sh`
4. Run the script with the following command:  
	`> ./plutonium-backend.sh /path/to/foundryvtt /path/to/foundrydata`
5. You will be asked which version of Foundry you have, simply type the number that is beside your version and hit enter.
6. Start FoundryVTT and enjoy

## How to Uninstall

Simply follow the above steps. If you have previously installed Plutonium, the script will detect the back up file and ask if you would like to uninstall the plutonium backend.

## Hardcode Paths

If you don't want to input the paths every time you want to run the script, you can edit just a couple of lines to hardcode your paths. Simply do the following:

1. Open the script in any text editor.
2. Find line 40 and replace `fvtt="$1"` with `fvtt="/path/to/my/foundry"`
3. Find line 41 and replace `data="$2"` with `data="/path/to/my/foundrydata"`
4. Delete lines 31 to 38 which look like the following:  
	```bash
	if [ $# -ne 2 ]; then
		echo "How to use this script"
		echo " > $0 <foundry_dir> <data_dir>"
		echo ""
		echo "    <foundry_dir>  Installation directory of FoundryVTT"
		echo "    <data_dir>     FoundryVTT Data directory"
		exit
	fi
	```
5. Save the file

**Note: I DO NOT recommend using relative paths like `./path/to/foundry` or `~/path/to/foundry` as relative paths are unreliable. Please use absolute paths instead like `/home/username/path/to/foundry`**

## Disclaimer

I wrote this for my own server environment and have not tested it outside of Ubuntu Server and WSL. I cannot guarantee it will work for everyone.
