# Find all PNG, JPEG, and JPG files in the current directory and subdirectories
find . -type f \( -name "*.png" -o -name "*.jpeg" -o -name "*.jpg" \) -print0 | while IFS= read -r -d $'\0' file; do
  echo "Processing: $file"  # Optional: Print the file being processed

  # Get the file extension (without the dot)
  ext="${file##*.}"

  # Create a temporary file for the converted image
  temp_file=$(mktemp --suffix=".$ext")

  # Convert and compress the image (quality setting varies - lower is more compression)
  convert "$file" -quality 50 "$temp_file"

  # Check if the conversion was successful
  if [[ $? -eq 0 ]]; then
      # Compare sizes to ensure compression actually happened (optional but recommended)
      original_size=$(stat -c "%s" "$file")
      compressed_size=$(stat -c "%s" "$temp_file")

      if (( compressed_size < original_size )); then
          # Replace the original file with the compressed one. You can add backup logic here if desired.
          mv "$temp_file" "$file"
          echo "Compressed: $file"
      else
          echo "Compression did not reduce size for: $file. Keeping original."
          rm "$temp_file" # Clean up the temporary file
      fi
  else
    echo "Error converting: $file"
    rm "$temp_file" # Clean up in case of error
  fi

done


# Find the 'convert' binary (and any other binaries you specify)
which convert
# Example for finding other binaries:
which identify  # ImageMagick's 'identify' command
which mogrify # ImageMagick's 'mogrify' command
# Or to find all ImageMagick binaries in a specific location (e.g. /usr/bin):
find /usr/bin -name "convert" -o -name "identify" -o -name "mogrify" 2>/dev/null # 2>/dev/null suppresses errors if not found.
