#!/bin/bash
# simple dictionary lookup script

# get content from clipboard
word=$(xclip -o -selection clipboard 2>/dev/null)

# exit if clipboard is empty
if [ -z "$word" ]; then
    notify-send --app-name="dictionary" "dictionary" "no text in clipboard"
    exit 1
fi

# clean the word (first word only, lowercase, remove only trailing punctuation)
word=$(echo "$word" | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/[.,!?;:]$//')

# exit if word is empty after cleaning
if [ -z "$word" ]; then
    notify-send --app-name="dictionary" "dictionary" "invalid word"
    exit 1
fi

# check if sdcv is installed
if ! command -v sdcv &> /dev/null; then
    notify-send --app-name="dictionary" "dictionary error" "sdcv not installed"
    exit 1
fi

# look up word in wordnet dictionary
definition=$(sdcv -n -u "WordNet" "$word" 2>&1)

# check if definition was found
if echo "$definition" | grep -qi "Nothing similar\|not found"; then
    notify-send --app-name="dictionary" "dictionary: $word" "no definition found"
else
    # clean the definition output and get first 2-3 definitions
    clean_def=$(echo "$definition" | \
                grep -v "^Found\|^-->\|^$word$\|^[[:space:]]*$" | \
                sed 's/^[[:space:]]*n [0-9]*://; s/^[[:space:]]*v [0-9]*://; 
                     s/^[[:space:]]*adj [0-9]*://; s/^[[:space:]]*adv [0-9]*://;
                     s/\[syn:.*\]//g; s/;.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | \
                grep -v "^[[:space:]]*$" | \
                head -n 5 | \
                awk '{print NR". "$0}' | \
                paste -sd '\n')
    
    if [ -n "$clean_def" ]; then
        # use printf to preserve newlines in notification
        notify-send --app-name="dictionary" -t 15000 "$word" "$(printf '%s' "$clean_def")"
    else
        notify-send --app-name="dictionary" "dictionary: $word" "no readable definition"
    fi
fi
