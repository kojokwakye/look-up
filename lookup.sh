#!/bin/bash
# Simple dictionary lookup script

# Get clipboard content
word=$(xclip -o -selection clipboard 2>/dev/null)

# Exit if clipboard is empty
if [ -z "$word" ]; then
    notify-send -- "Dictionary" "No text in clipboard"
    exit 1
fi

# Clean the word (first word only, lowercase)
word=$(echo "$word" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')

# Look up word in WordNet (English dictionary only)
definition=$(sdcv -n -u "WordNet" "$word" 2>&1)

# Check if definition was found
if echo "$definition" | grep -qi "Nothing similar\|not found"; then
    notify-send -- "Dictionary: $word" "No definition found"
else
    # Extract and clean the definition
    clean_def=$(echo "$definition" | \
                grep -v "^Found\|^-->\|^test\|^$word$" | \
                sed 's/^[[:space:]]*n [0-9]*://; s/^[[:space:]]*v [0-9]*://; s/\[syn:.*\]//g' | \
                sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
                grep -v "^[[:space:]]*$" | \
                head -n 3 | \
                tr '\n' ' ' | \
                sed 's/[[:space:]]\+/ /g')
    
    notify-send -- "$word" "$clean_def"
fi