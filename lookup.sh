#!/bin/bash
# simple dictionary lookup script

# get content from clipboard
word=$(xclip -o -selection clipboard 2>/dev/null)

# exit if clipboard is empty
if [ -z "$word" ]; then
    notify-send "dictionary" "no text in clipboard"
    exit 1
fi

# clean the word (first word only, lowercase, remove punctuation)
word=$(echo "$word" | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z]//g')

# exit if word is empty after cleaning
if [ -z "$word" ]; then
    notify-send "dictionary" "invalid word"
    exit 1
fi

# check if sdcv is installed
if ! command -v sdcv &> /dev/null; then
    notify-send "dictionary error" "sdcv not installed"
    exit 1
fi

# look up word in wordnet dictionary
definition=$(sdcv -n -u "WordNet" "$word" 2>&1)

# check if definition was found
if echo "$definition" | grep -qi "Nothing similar\|not found"; then
    notify-send "dictionary: $word" "no definition found"
else
    clean_def=$(echo "$definition" | \
                grep -v "^Found\|^-->\|^test\|^[[:space:]]*$" | \
                sed 's/^[[:space:]]*n [0-9]*://; s/^[[:space:]]*v [0-9]*://; 
                     s/^[[:space:]]*adj [0-9]*://; s/^[[:space:]]*adv [0-9]*://;
                     s/\[syn:.*\]//g; s/^[[:space:]]*//; s/[[:space:]]*$//' | \
                grep -v "^[[:space:]]*$" | \
                head -n 3)
    
    if [ -n "$clean_def" ]; then
        notify-send -t 8000 "$word" "$clean_def"
    else
        notify-send "dictionary: $word" "no readable definition"
    fi
fi