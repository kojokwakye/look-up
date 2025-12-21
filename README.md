# dictionary lookup tool

simple offline dictionary tool that shows word definitions in desktop notifications.

## prerequisites

you need the following packages installed:
- `xclip` - for clipboard access
- `wordnet` - comprehensive english dictionary database

## installation

### step 1: install required packages
```bash
sudo apt update
sudo apt install xclip wordnet
```

verify installation:
```bash
# test wordnet
wn test -over

# test xclip
echo "test" | xclip -selection clipboard
xclip -o -selection clipboard
```

### step 2: create the script directory
```bash
mkdir -p ~/Documents/script
```

### step 3: create the lookup script
```bash
nano ~/Documents/script/lookup.sh
```

paste this content:
```bash
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
```

save and exit (ctrl+x, then y, then enter).

### step 4: make the script executable
```bash
chmod +x ~/Documents/script/lookup.sh
```


### step 6: set up keyboard shortcut

1. open **settings** → **keyboard** → **keyboard shortcuts**
2. scroll down and click **"view and customize shortcuts"**
3. click **"custom shortcuts"** at the bottom
4. click the **"+"** button to add a new shortcut
5. fill in the details:
   - **name:** `dictionary lookup`
   - **command:** `/home/YOUR_USERNAME/Documents/script/lookup.sh`
     - replace `YOUR_USERNAME` with your actual username (find it with `whoami`)
6. click **"set shortcut"**
7. press **ctrl+shift+d** on your keyboard
8. click **"add"** to save

## usage

1. **select and copy** any word using your mouse and ctrl+c
2. **press ctrl+shift+d** to see the definition
3. the definition will appear as a desktop notification for 20 seconds


## uninstall

1. remove the keyboard shortcut from settings → keyboard → keyboard shortcuts
2. delete the script:

```bash
rm ~/Documents/script/lookup.sh
rmdir ~/Documents/script  # if empty
```
3. remove wordnet:
```bash
sudo apt remove wordnet 
```

## demo 

https://github.com/user-attachments/assets/90a3ca62-ec3f-4bfa-8feb-8c8165867dc3




