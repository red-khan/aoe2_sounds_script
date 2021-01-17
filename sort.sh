#!/bin/bash

api_key="" #Needs an API key, see https://developers.google.com/sheets/api/guides/authorizing#APIKey
declare -A civs
declare -a actions

echo "Checking API key presense"
if [ "${#api_key}" -gt 0 ]; then
    echo "API key present, continuing"
else
	echo "No API key, please enter one into script. For getting one see https://developers.google.com/sheets/api/guides/authorizing#APIKey"
	exit 1
fi

echo "Checking for arrays.txt"
if [ -f arrays.txt ]; then
	echo "arrays.txt found, continuing"
else
	echo "No arrays.txt found, please run arrays.sh first"
	exit 1
fi

#Preparing folders and files
echo "Checking for previous folder existence"
if [ -d sorted_files ]; then
	echo "Previous folder found, clearing it's content"
	rm sorted_files/*
else
	echo "No previous folder found, creating"
	mkdir sorted_files
fi

echo "Checking for previous missing file log"
if [ -f files.log ]; then
	echo "Previous log found, deleting"
	rm files.log
else
	echo "No previous log found, continuing"
fi

#Populating arrays with pre-prepared values created by arrays.sh script
source arrays.txt

# Preparinf data - retrieving data (File and FileID columns) from Google Sheets and storing it locally
# https://docs.google.com/spreadsheets/d/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw/edit?usp=sharing
curl -s -o audio_sources.json "https://sheets.googleapis.com/v4/spreadsheets/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw/values:batchGet?ranges=Audio%20Sources%20-%20Speech!A4:A24357&ranges=Audio%20Sources%20-%20Speech!B4:B24357&key=${api_key}"

#Starting
column=''
for column in "${!civs[@]}" ; do

	row=''
	for row in "${!actions[@]}" ; do
		echo "Looking in cell $column$row (${civs[$column]}-${actions[$row]}) in \"Unit Voices - Legacy IDs\""
		legacy_file_id=$(curl -s "https://sheets.googleapis.com/v4/spreadsheets/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw/values/Unit%20Voices%20-%20Legacy%20IDs!${column}${row}?key=${api_key}" | jq --raw-output '.values[]|.[]')
		echo "Value (legacy file ID) in cell $column$row is $legacy_file_id"

		if [ $legacy_file_id = "-" ]; then
			echo "This an invalid value, skipping"
		else
			
			# Resseting indices array from previous loops's values
			unset indices
			
			# Finding indices (row numbers) of rows where current legacy file ID is found and putting them into ${indices[@]}
			readarray -t indices < <(jq --arg f "$legacy_file_id" $'.valueRanges[]|select(.range == "\'Audio Sources - Speech\'!A4:A24357")|.values|flatten|indices($f)|.[]' audio_sources.json)
			
			#Setting control boolean
			file_found=false
			# Finding "FileID" values for current set of rows where legacy file ID was found
			file_id_row=''
			for file_id_row in "${indices[@]}" ; do
				file_id=$(jq --argjson v ${file_id_row} --raw-output $'.valueRanges[]|select(.range == "\'Audio Sources - Speech\'!B4:B24357")|.values|flatten|.[$v]' audio_sources.json)
				echo "Found FileID for this value in \"Audio Sources - Speech\" - $file_id"
				echo "Checking if there is a file with ID $file_id"
				if [ -f files/$file_id.ogg ]; then
					echo "FILE FOUND!"
					file_found=true
					echo "Copying and renaming the found file"
					cp -v "files/$file_id.ogg" "sorted_files/${civs[$column]} ${actions[$row]} AoE2.ogg"
				else
					echo "No file with ID $file_id found"
				fi
			done
			if ! $file_found ; then
			echo "NO FILE FOR ${civs[$column]} ${actions[$row]}  and ID $legacy_file_id FOUND! WRITING TO files.log" | tee --append files.log
			fi
		fi

		sleep 1.5 #Waiting so not to exceed API's usage limits https://developers.google.com/sheets/api/limits
	done
done
