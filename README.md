# rclone-sync

Using rclone in a bash script to save project folders to S3 bucket.

## How

This is a bash script, it is available for Linux and Mac terminal prompt, or GitBash terminal for Windows.

Basically `$ rclone-sync` will guide you clearly.

It checks if there is a file that requires privacy then encodes its data into another file with '.encoded' extension and excludes it during sync. For example `.env` file becomes `.env.encoded` as encoded and gets synced to remote but not the original file.

Also user gets a log file `.sync.log` in the same folder and a report text as a return.

## Requirements

rclone-sync has dependencies:
- [now: gets date instantly in desired format](https://github.com/emrea-works/now)
- [rclone](https://rclone.org/)

## New Things

More modular and lighter syncing script is ready: **rcs**

`$ rcs <remote_name> <bucket_name>`

- Requires two arguments as local and destination paths
- Displays sync report

Another one is for backup with a compressed directory to close the project

- Uses tar in zstd format to compress the entire directory, excluded defaults
- Copies the compressed file into the remote bucket that is given as argument
- Checks the file location at remote, presents a tree as an output at the end
- Offers to cleanup the local directory from the excluded ones

Bucket name term comes from S3 clouds, it can be used as root folder name in any remote. 
