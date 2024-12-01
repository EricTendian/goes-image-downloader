#!/bin/bash
set -e

cd "$(dirname "$0")"

# Don't bother downloading the image if we're not connected to the internet
if ! ping -q -c 1 -W 1 google.com >/dev/null; then
	exit 1
fi

export PATH="${PATH}:/opt/homebrew/bin"

if ! command -v magick &> /dev/null; then
	brew install imagemagick
fi

if ! command -v wallpaper &> /dev/null; then
	brew install --build-from-source wallpaper
fi

CURRENT_DATETIME=$(date +"%Y%m%d%H%M")

# Get the resolution of the display
RESOLUTION_LINE=$(system_profiler SPDisplaysDataType | grep Resolution)
X_RESOLUTION=$(echo ${RESOLUTION_LINE} | awk '{print $2}')
Y_RESOLUTION=$(echo ${RESOLUTION_LINE} | awk '{print $4}')
RESOLUTION="${X_RESOLUTION}x${Y_RESOLUTION}"

# Download the latest image from NOAA
curl -sSfL https://cdn.star.nesdis.noaa.gov/GOES16/ABI/FD/GEOCOLOR/latest.jpg | \
# We need to resize the image to 90% of the height to make space for the menu bar/notch
magick - \
	-resize ${X_RESOLUTION}x$((${Y_RESOLUTION} * 90 / 100)) \
	-background black \
	-gravity center \
	-extent ${RESOLUTION} \
	${CURRENT_DATETIME}.jpg
# Set the image as the wallpaper - we are using CURRENT_DATETIME so MacOS detects a change and updates the wallpaper
wallpaper set ${CURRENT_DATETIME}.jpg --scale fit --fill-color 000000

# Delete all images except the current one
find . -type f -name '*.jpg' ! -name "${CURRENT_DATETIME}.jpg" -delete
