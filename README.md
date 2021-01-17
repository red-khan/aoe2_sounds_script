# aoe2_sounds_script
A script to sort out unit speech audio files in Age of Empires 2: Definitive Edition

Script uses Google spreadsheet -  https://docs.google.com/spreadsheets/d/1bczdFQksnbLnjI5zAkw-mSpb9MnnxxEkHDiz1PftIHw <br>
taken from audio modding guide - https://steamcommunity.com/sharedfiles/filedetails/?id=1915891079

Instructions:
1. Get API key and put it into script inside quotation marks in api_key="" <br>
https://developers.google.com/sheets/api/guides/authorizing#APIKey

2. Extract all files from wwise\SFX.bnk to a folder named `files` in the same folder as script files. File names should be `some number`.ogg, for example `784593.ogg`
Best option, in my opinion, is foobar2000 with vgmstream plugin <br>
https://www.foobar2000.org <br>
https://www.foobar2000.org/components/view/foo_input_vgmstream <br>
Don't forget to choose best quality for conversion and afterwards rename files with command <br>
`rename -v 's/.*\(([0-9]*)\)/$1/' *.ogg`

3. Start array.sh It will make a file arrays.txt that is needed for creation of arrays for the next script<br>
Note: Make sure that all values are populated, sometimes for some reason one or two of them are empty. If necessary change value of all three `sleep` commands from `1.5` to `2` or even `3`

4. Start sort.sh Sorted and renamed files will be in `sorted_files` folder
