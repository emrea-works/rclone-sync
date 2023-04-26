# rclone-sync

Using rclone in a bash script to save project folders to S3 bucket.

## How

This is a bash script, it is available for Linux and Mac terminal prompt, or GitBash terminal for Windows.

Basically `$ rclone-sync` will guide you clearly.

It checks if there is a file that requires privacy then encodes its data into another file with '.encoded' extension and excludes it during sync. For example `.env` file becomes `.env.encoded` as encoded and gets synced to remote but not the original file.

Also user gets a log file `.sync.log` in the same folder and a report text as a return.
