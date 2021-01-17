#!/bin/bash

api_key="" #Needs an API key, see https://developers.google.com/sheets/api/guides/authorizing#APIKey
declare -A civs
declare -a actions
json_index=0

echo "Checking API key presense"
if [ "${#api_key}" -gt 0 ]; then
    echo "API key present, continuing"
else
	echo "No API key, please enter one into script. For getting one see https://developers.google.com/sheets/api/guides/authorizing#APIKey"
	exit 1
fi

echo "Checking for previous file existence"
if [ -f arrays.txt ]; then
    echo "Previous file found, deleting"
	rm arrays.txt
else
	echo "No previous file found, continuing"
fi

echo "Starting to retrieve civs' values"
for i in {D..Z}
do
	echo "Retrieving column $i header value"
	civs[$i]=$(curl -s "https://sheets.googleapis.com/v4/spreadsheets/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw/values/Unit%20Voices%20-%20Legacy%20IDs!${i}2?majorDimension=COLUMNS&key=${api_key}" | jq -r '.values[0] | .[]')
	((json_index=json_index+1))
	echo "Writing column $i header to file"
	echo "civs[$i]='${civs[$i]}'" | tee --append arrays.txt
	sleep 1.5 #Waiting so not to exceed API's usage limits https://developers.google.com/sheets/api/limits
done

for i in {A..A}{A..L}
do
	echo "Retrieving column $i header value"
	civs[$i]=$(curl -s "https://sheets.googleapis.com/v4/spreadsheets/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw/values/Unit%20Voices%20-%20Legacy%20IDs!${i}2?majorDimension=COLUMNS&key=${api_key}" | jq -r '.values[0] | .[]')
	((json_index=json_index+1))
	echo "Writing column $i header value to file"
	echo "civs[$i]='${civs[$i]}'" | tee --append arrays.txt
	sleep 1.5 #Waiting so not to exceed API's usage limits https://developers.google.com/sheets/api/limits
done

echo "Done with civs, starting to retrieve actions' values"
#resetting index for actions array
json_index=0

for i in {4..68}
do
	echo "Retrieving row $i header value"
	actions[$i]=$(curl -s "https://sheets.googleapis.com/v4/spreadsheets/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw/values/Unit%20Voices%20-%20Legacy%20IDs!B${i}?key=${api_key}" | jq -r '.values[0] | .[]')
	((json_index=json_index+1))
	echo "Writing row $i value to file"
	echo "actions[$i]='${actions[$i]}'" | tee --append arrays.txt
	sleep 1.5 #Waiting so not to exceed API's usage limits https://developers.google.com/sheets/api/limits
done

# Code for printing out array
#echo "Printing out array"
#echo "${civs[@]}"
#declare -p civs | tr ' ' '\n'