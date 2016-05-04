#!/bin/bash

# Function gets a character from input
getc() {
    IFS= read -r -n1 -d '' "$@"
}

print() {

        # String manipulation (create lowercase string)
        buffer=${buffer,,}
        # String manipulation (remove "."s from string)
        tempBuffer=${buffer//.}

        # Capitalizes words after new paragraph, sentence, or not found in wordlist
        if [ "$capital" -eq 1 ] || [ "$(grep -cim1 "$tempBuffer" wordlist)" -eq 0 ]
        then
            buffer=${buffer^}
            capital=0
        fi
        
        buffer+=" "
        printf "$buffer"
        buffer=""

        (( columns += 1 ))

}

# Variables
columns=0
capital=0
count=0
prev=""
current=""
next=""
tempBuffer=""
buffer=""
elipse="[.][.][.]"
letter="[0-9a-zA-Z,-/]"

# Reads text from file or stdin
while getc next
do

    # Maintains the 100 column size limit
    if [ "$columns" -ge 100 ]
    then
        printf "\n"
        columns=0
    fi

    # Exception- handles the elipse- prints buffer
    if [[ "$buffer" =~ $elipse ]] 
    then
        print
    fi

    # Adds char to word buffer 
    if [[ "$next" =~ $letter ]]
    then
        buffer+="$next"
    # Checks for a paragraph
    elif [ "$current" = $'\n' ] && [ "$next" = $'\n' ]
    then
        printf "\n\n"
        columns=0
        capital=1
    # Checks for first word or end of sentence with period and space ". "
    elif [ "$count" -eq 0 ] || [ "$prev" = $'.' ] && [ "$next" = $' ' ]
    then
        capital=1
    # Checks for end of sentence with period and newline ".\n"
    elif [ "$prev" = $'.' ] && [ "$next" = $'\n' ]
    then
        capital=1
    # Prints buffer
    elif [ "$next" = $' ' ] || [ "$next" = $'\n' ]
    then
        print
    fi

    prev="$current"
    current="$next"
    (( columns += 1 ))
    (( count += 1 ))

done < "${1:-/dev/stdin}"
