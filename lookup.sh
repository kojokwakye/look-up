#!/bin/bash

# get word from clipboard
word=$(xclip -o -selection clipboard 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/[.,!?;:]$//')

# exit if empty
if [ -z "$word" ]; then
    notify-send --app-name="dictionary" "dictionary" "no word in clipboard"
    exit 1
fi

# get definition using wordnet
result=$(wn "$word" -over 2>&1)

# check if found
if echo "$result" | grep -qi "no information available"; then
    notify-send --app-name="dictionary" "dictionary: $word" "no definition found"
    exit 1
fi

# extract first 2 definitions
definition=$(echo "$result" | grep "^[0-9]\." | head -n 2 | sed 's/^[0-9]*\. //' | tr '\n' ' ')

# show it
notify-send --app-name="dictionary" -t 20000 "$word" "$definition"