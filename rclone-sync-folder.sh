#!/bin/bash

PWD=$(pwd)
LOCAL=$1
DESTINATION=$2 
SYNCING_TARGET=$DESTINATION/$LOCAL

echo "Check the path to be synced: remote:storj.sync/$SYNCING_TARGET";
read;

rclone sync $LOCAL remote:storj.sync/$SYNCING_TARGET \
  --exclude 'node_modules/**' \
  --exclude '.next/**' \
  --exclude 'target/**' -P
