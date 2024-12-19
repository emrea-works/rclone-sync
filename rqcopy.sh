#!/bin/bash

# Path to the colors script
COLORS_SCRIPT=$USERBIN/bash_styling

# Check if the colors script exists and is readable
if [[ ! -f "$COLORS_SCRIPT" ]]; then
  # echo "Error: Colors script not found at $COLORS_SCRIPT"
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  UNDERLINE='\033[4m'
  NC='\033[0m' # No Color, no style
fi

# if [[ ! -r "$COLORS_SCRIPT" ]]; then
#   echo "Error: Colors script is not readable at $COLORS_SCRIPT"
# fi

# Source the colors script
source "$COLORS_SCRIPT"


remote=$1
bucket=$2
path=$(pwd | cut -d'/' -f5-)
dir=$(basename "$(pwd)")
compressed="$dir.tar.zst"

excluded=(
  --exclude 'node_modules/**'
  --exclude '.next/**'
  --exclude 'target/**'
  --exclude '*.rs.bk'
  --exclude '*.swp'
)

init() {
  echo -e "Will compress content of this folder ${RED}${UNDERLINE}$path${NC}"
  echo -e "and upload to the given remote as ${YELLOW}${UNDERLINE}/$bucket/$path${NC}"
  read -p "Proceed? (y/n) " answer
  case $answer in
    [Yy]|[Yy][Ee][Ss])
      backup
      ;;
    [Nn]|[Nn][Oo])
      echo "Canceled, exiting."
      # exit 0
      ;;
    *)
      echo "Not answered properly, exiting..."
      # exit 1
      ;;
  esac
}

cleanup() {
  echo -e 'Do you need cleanup (node_modules, lock file, etc...)? (y/n)'
  read -p "Proceed? (y/n) " answer
  case $answer in
    [Yy]|[Yy][Ee][Ss])
      if [ -d "$path/node_modules" ]; then
        echo "Cleaning up..."
        rm -rf "$path/node_modules"
        echo "Done."
      else
        echo "Nothing to clean up."
      fi
      ;;
    *)
      echo "All good."
      ;;
  esac
}

backup() {
  echo -e "Compressing..."
  if tar --zstd -cvf "$compressed" "${excluded[@]}" .[^.]* *; then
    echo -e "Copying to remote..."
    if rclone copy "$compressed" "$remote:$bucket/$path" --update --progress; then
      echo -e "Done. Checking remote for $compressed..."
      if rclone lsf "$remote:$bucket/$path" | grep -q "$compressed"; then
        rclone tree "$remote:$bucket"
        echo "File uploaded successfully."
      else
        echo "File not found on remote."
        # exit 1
      fi
    else
      echo "Error uploading file."
      # exit 1
    fi
  else
    echo "Error compressing file."
    # exit 1
  fi
}

if [ $# -ne 2 ]; then
  echo "Usage: $0 <remote_name> <bucket>"
  # exit 1
fi

init
cleanup
