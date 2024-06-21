#!/bin/bash

# Function to show the usage of the script
usage() {
    echo "Usage: $0 <script-name> [logfile-path]"
    echo "  <script-name>: Path to the script to run"
    echo "  [logfile-path]: Optional path to the logfile"
}

# Check if a script name was provided
if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

SCRIPT="$1"

# Check if a log file path was provided
if [ "$#" -eq 2 ]; then
    LOGFILE="$2"
    LOGFILE_OPTION="-Logfile $LOGFILE"
    # If a logfile already exists, delete it
    if [ -f "$LOGFILE" ]; then
        rm "$LOGFILE"
    fi
else
    echo "Warning: No logfile path provided. Logging will not be performed."
    LOGFILE_OPTION=""
fi

# Run the specified script in a new detached screen session
echo screen -dmL $LOGFILE_OPTION -S "$(basename "$SCRIPT" .sh)" "$SCRIPT"
screen -dmL $LOGFILE_OPTION -S "$(basename "$SCRIPT" .sh)" "$SCRIPT"
