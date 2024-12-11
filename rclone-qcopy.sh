#!/bin/bash

set -e
set -u

# Ex: `rclone-quick-sync <remote_name> <bucket>`
# compress the folder with zstd
# sends the compress file to the given folder in given remote

path=$(pwd)
dir=$(basename "$path")
compressed="$dir.tar.zst"
remote=$1
bucket=$2

excluded=(
  --exclude "node_modules/**"
  --exclude ".next/**"
  --exclude "target/**"
  --exclude "*.rs.bk"
  --exclude "*.swp"
)

init() {
  echo -e 'Will compress content of this folder and upload to the given remote.'
  read -p "Proceed? (y/n) " answer
  case $answer in
    [Yy]|[Yy][Ee][Ss])
      backup
      ;;
    [Nn]|[Nn][Oo])
      echo "Canceled, exiting."
      exit 0
      ;;
    *)
      echo "Not answered properly, exiting..."
      exit 1
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
  echo -e 'Compressing...'
  if tar --zstd -cvf "$compressed" .[^.]* * "${excluded[@]}"; then
    echo -e 'Copying to remote...'
    if rclone copy "$path/$compressed" "$remote:$bucket/$path" --update --progress; then
      echo -e 'Done. Checking remote for "$compressed"...'
      if rclone lsf "$remote:$path" | grep -q "$compressed"; then
        echo "File uploaded successfully."
      else
        echo "File not found on remote."
        exit 1
      fi
    else
      echo "Error uploading file."
      exit 1
    fi
  else
    echo "Error compressing file."
    exit 1
  fi
}

if [ $# -ne 2 ]; then
  echo "Usage: $0 <remote_name> <bucket>"
  exit 1
fi

init
cleanup
