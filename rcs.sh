#!/bin/bash

# Define the default syncing paths
source_dir=$1
destination_dir=$2

# Check if both arguments are provided
if [ -z "$source_dir" ] || [ -z "$destination_dir" ]; then
  echo "Error: You must provide both source and destination directories."
  echo "Usage: $0 <source_dir> <destination_dir>"
  return 1  # or simply do not exit
fi

# Define the items to be excluded
exclude_items="*.log *.tmp **/node_modules/** **/.next/**"

# Get more items to be excluded from the user
echo "Enter items to exclude (separated by spaces):"
read additional_excludes
exclude_items="$exclude_items $additional_excludes"

# Prompt the user if they agree to sync the given folder
echo "Do you want to sync $source_dir to $destination_dir? (y/n)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
  # Check if the arguments given

  # Run the cloning rclone command with specific arguments to exclude
  rclone sync "$source_dir" "$destination_dir" --progress \
    --exclude "$exclude_items" | tee "sync_report.txt"

  # Check the sync process result
  if [ $? -eq 0 ]; then
      echo "Sync successful."
  else
      echo "Sync failed."
  fi

  # Return the sync report
  cat "sync_report.txt"
else
  echo "Sync cancelled."
fi
