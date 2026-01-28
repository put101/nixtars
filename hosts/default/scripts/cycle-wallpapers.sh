#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/nixtars/wallpapers"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
fi

# Enable nullglob to handle cases where no matches exist for a pattern
shopt -s nullglob

# Find image files (jpg, png, jpeg, webp)
files=("$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp)

# Check if any files found
if [ ${#files[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Pick a random file
random_file="${files[RANDOM % ${#files[@]}]}"

echo "Setting wallpaper: $random_file"

# Kill existing swaybg instances to avoid duplicates/memory leaks
pkill swaybg

# Run swaybg
# -m fill: scales the image to fill the screen
# & detaches it
nohup swaybg -i "$random_file" -m fill > /dev/null 2>&1 &
