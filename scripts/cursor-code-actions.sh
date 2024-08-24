#!/bin/bash

function cursor-code-install() (
  # Download Cursor AppImage to a temporary directory
  temp_dir=$(mktemp -d)
  wget "https://download.todesktop.com/230313mzl4w4u92/cursor-0.39.6-build-240819ih4ta2fye-x86_64.AppImage" -O "$temp_dir/cursor.AppImage"

  # Make the AppImage executable
  chmod +x "$temp_dir/cursor.AppImage"

  # Move the AppImage to /usr/local/bin/cursor-code
  sudo mv "$temp_dir/cursor.AppImage" /usr/local/bin/cursor-code

  # Clean up the temporary directory
  rm -rf "$temp_dir"

)
