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

## Disclaimer

I wrote this for my own server environment and have not tested it outside of Ubuntu Server and WSL. I cannot guarantee it will work for everyone.
