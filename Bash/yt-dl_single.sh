#!/bin/bash

#Stores the input of the user (the YouTube Playlist Link) into a variable
echo "Enter the YouTube Playlist link"
read playlist

echo " "
#Downloads the YouTube Playlist
youtube-dl -o '~/LOCATION/%(title)s.%(ext)s' -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --add-metadata --write-description --write-info-json --write-annotations --write-thumbnail --restrict-filesnames $playlist