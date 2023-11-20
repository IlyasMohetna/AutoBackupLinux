#!/bin/bash

declare -a paths=(
    "/Users/ilyasmohetna/Documents/test/a.txt"
    "/Users/ilyasmohetna/Documents/test/a"
)

dest="/Users/ilyasmohetna/Documents/test/external_disk"
log_file="log_file.log"
current_datetime=$(date +"%Y-%m-%d_%H-%M-%S")
backup_prefix="backup_"
backup_extension=".zip"
max_backups=5

# Clean up old backups
cleanup_old_backups() {
    cd "$dest" || exit
    backups=$(ls -t "$backup_prefix"*"$backup_extension" 2>/dev/null)
    num_backups=$(echo "$backups" | wc -l)

    if [ "$num_backups" -gt "$max_backups" ]; then
        excess_backups=$((num_backups - max_backups))
        echo "Cleaning up old backups..."
        echo "$backups" | tail -n "$excess_backups" | xargs rm -f
        echo "Old backups cleaned up."
    fi
}


# Create backup
create_backup() {
    # Ensure the destination directory exists
    mkdir -p "$dest"

    # Create a new backup without a suffix
    zip_filename="$dest/$backup_prefix$current_datetime$backup_extension"
    echo "Zipping: ${paths[@]}"
    (cd "$(dirname "${paths[0]}")" && zip -r "$zip_filename" "$(basename "${paths[@]}")") 2>> "$log_file"

    if [ $? -eq 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Successfully zipped: ${paths[@]} to $zip_filename" >> "$log_file"
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Failed to zip: ${paths[@]}" >> "$log_file"
        echo "Error details:" >> "$log_file"
        tail -n 10 "$log_file" >> "$log_file"  # Appending the last 10 lines of the log for error details
    fi
}

# Main script
cleanup_old_backups
create_backup
