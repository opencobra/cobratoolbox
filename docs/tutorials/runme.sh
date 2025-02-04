#!/bin/bash
	
#sed -i 's/<li><p><a class="reference internal" href="/QWERTY/g' $1
#sed -i 's/"><span class="doc">tutorialNoName<\/span><\/a><\/p><\/li>//g' $1

while read line
	do
		if [[ $line == QWERTY* ]] 
		then
		url=$(echo "<li><p><a\ class=\"reference\ internal\"\ href=\"${line}\"><span\ class=\"doc\">${line}<\/span><\/a><\/p><\/li>")
		echo "sed -i 's/$line/$url/' $1" >> COMMANDS
		
		fi
	done
