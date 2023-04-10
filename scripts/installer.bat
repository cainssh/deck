curl -L -C - https://github.com/deck-app/wsl-installer/releases/download/v1.0.0/deck-app.tar --output deck-app.tar
expected_hash="a8f8e03ab0fe59d5afca54e60ee08340"
actual_hash=$(sha256sum deck-app.tar | cut -d ' ' -f 1)
if [ "$actual_hash" != "$expected_hash" ]; then
    echo "Error: SHA-256 hash mismatch for downloaded file."
    exit 1
fi
wsl_instance_name="deck-app"
wsl_instance_path="C:\deck-app"
wsl_import_command="wsl --import $wsl_instance_name $wsl_instance_path deck-app.tar"
wsl_set_version_command="wsl --set-version $wsl_instance_name 2"
if ! $wsl_import_command || ! $wsl_set_version_command; then
    echo "Error: Failed to import WSL instance or set version."
    exit 1
fi
# Start the WSL instance and create a directory
wsl_start_command="wsl -s $wsl_instance_name"
wsl_mkdir_command="wsl -d $wsl_instance_name mkdir /home/deck-projects"
if ! $wsl_start_command || ! $wsl_mkdir_command; then
    echo "Error: Failed to start WSL instance or create directory."
    exit 1
fi
