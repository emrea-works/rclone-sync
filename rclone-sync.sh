#!/bin/bash

# Defining the default syncing paths
remote='remote'
folder_to_sync=$(pwd)
bucket_name='auto.sync'

# Define the items to be excluded
EXCLUDED=(
  --exclude "/'$SECRET'" 
  --exclude "node_modules/**" 
  --exclude ".next/**" 
)

# Usage explanation and pause the script
echo -e "
Recommendation: 

This program takes the **current** path then saves the folder as the same 
hierarchy at remote. So it's recommended to use it while inside the folder 
which is desired to be synced. Plus, saves a log file in the current folder.

Example:

  \e[36mcd /path/to/the/folder && rclone-sync ⎆\e[0m

"


if [[ $1 == '--no-prompt' ]]; then
  echo "Syncing $folder_to_sync ..."
else
  # Prompt user if agrees the current folder is to be synced
  echo -e "Then, syncing \e[33m$folder_to_sync\e[0m... [y/N]? "; read answer
  case $answer in
    [Yy]|[Yy][Ee][Ss])
      echo "Syncing $folder_to_sync ..."
      ;;
    [Nn]|[Nn][Oo])
      echo "Canceled, exiting."
      exit 1
      ;;
    *)
      echo "Not answered properly, exiting..."
      exit 0
      ;;
  esac
fi 

# Define a secret file needed to be encoded
SECRET='.env'

# Check if .env file exists
if [ -e "$folder_to_sync/$SECRET" ]; then
    # Encode secret file into secret.encode
    xxd -p $folder_to_sync/$SECRET > $folder_to_sync/$SECRET.encoded;
else
    echo "$SECRET file does not exist, passed. syncing continues..."
fi

# Run cloning command with specific arguments to exclude
rclone sync $folder_to_sync $remote:$bucket_name$folder_to_sync \
  --progress --create-empty-src-dirs "${EXCLUDED[@]}" "$1" "$2" 

# After sync, remove the encoded file from the local dir.
rm $folder_to_sync/$SECRET.encoded;

# Save report in a file in the local dir.
echo -e "Synced $(now) at $remote:$bucket_name." >> .sync.log

# Return sync report
echo -e "\n🟢 Sync ended $(now), written in './.sync.log'. \n"

# Check sync process
rclone check $(pwd) $remote:$bucket_name$folder_to_sync "${EXCLUDED[@]}"
echo -e "\n🟡 $SECRET.encoded and .sync.log files are produced from this program, 
not part of your synced folder.\n"
