# look-up
basic dictonary for linux (ubuntu)

## prerequisites

you need the following packages installed:
- `xclip` - for clipboard access
- `sdcv` - command-line dictionary tool
- `stardict` dictionaries - the actual dictionary data

## step 1: install required packages

```bash
sudo apt update
sudo apt install xclip sdcv stardict-common
```

verify installation:
```bash
# test sdcv works
sdcv test

# test xclip works
echo "test" | xclip -selection clipboard
xclip -o -selection clipboard
```

## step 2: create the lookup Script

create a directory for your scripts:
```bash
mkdir -p ~/Documents/script
```

create the script file:
```bash
nano ~/Documents/script/lookup.sh
```

paste this content:
```bash
#!/bin/bash
# Simple dictionary lookup script

# get content
word=$(xclip -o -selection clipboard 2>/dev/null)

# exit if clipboard is empty
if [ -z "$word" ]; then
    notify-send -- "Dictionary" "No text in clipboard"
    exit 1
fi

# clean the word (first word only, lowercase)
word=$(echo "$word" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')

# look up word in wordnet dictionary
definition=$(sdcv -n -u "WordNet" "$word" 2>&1)

# check if definition was found
if echo "$definition" | grep -qi "Nothing similar\|not found"; then
    notify-send -- "Dictionary: $word" "No definition found"
else
    clean_def=$(echo "$definition" | \
                grep -v "^Found\|^-->\|^test\|^[[:space:]]*$" | \
                sed 's/^[[:space:]]*n [0-9]*://; s/^[[:space:]]*v [0-9]*://; s/\[syn:.*\]//g' | \
                grep -v "^[[:space:]]*$" | \
                head -n 3)
    
    notify-send -- "$word" "$clean_def"
fi
```

save and exit (Ctrl+X, then Y, then Enter).

make the script executable:
```bash
chmod +x ~/Documents/script/lookup.sh
```

## step 3: test the script 

1. copy a word (select "hello" and press Ctrl+C)
2. run the script:
```bash
~/Documents/script/lookup.sh
```

you should see a notification with the definition of "hello".

## step 4: set up keyboard shortcut

1. Open **settings** → **keyboard** → **keyboard shortcuts**
2. Scroll down and click **"view and customize Shortcuts"**
3. Click **"custom shortcuts"** at the bottom
4. Click the **"+"** button to add a new shortcut
5. Fill in the details:
   - **Name:** `Dictionary Lookup`
   - **Command:** `/home/YOUR_USERNAME/Documents/script/lookup.sh`
     - Replace `YOUR_USERNAME` with your actual username (e.g., `/home/kwakye/Documents/script/lookup.sh`)
6. click **"set shortcut"**
7. press **Ctrl+Shift+D** on your keyboard
8. click **"add"** to save

## usage

1. **select and copy** any word using your mouse and Ctrl+C
2. **press Ctrl+Shift+D** to see the definition
3. The definition will appear as a desktop notification for 10 seconds 

https://github.com/user-attachments/assets/0d9100e9-2f03-4ec3-868e-31398ef98619

 

