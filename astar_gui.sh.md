

---

# A\* Pathfinding GUI Script – Line-by-Line Explanation

This Bash script provides a **graphical user interface (GUI)** using `zenity` to interact with map generation and A\* pathfinding utilities. It supports generating random maps, running simple A\* (with output in a GUI window), running a colored A\* visualization (in a terminal), and viewing the current map.

---

## 1. Script Setup and Constants

```bash
#!/bin/bash
```
> **Shebang**: Tells the system to execute this script using `bash`.

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```
> Determines the **absolute path** of the directory containing this script, even if it’s called from another location.  
> - `dirname "${BASH_SOURCE[0]}"` → gets the directory of the script  
> - `cd ... && pwd` → resolves symlinks and returns canonical path

```bash
MAP_FILE="$SCRIPT_DIR/maps/random_map.txt"
```
> Defines the **default path** for the generated map file.

---

## 2. Helper Function: Show Error Dialog

```bash
show_error() {
    zenity --error --text="$1" --width=300
}
```
> Displays a **graphical error dialog** using `zenity`.  
> - `$1` is the error message passed to the function  
> - Fixed width for consistent UI

---

## 3. Function: Generate New Random Map

```bash
generate_new_map() {
```
> Begins the `generate_new_map` function.

```bash
    if ! "$SCRIPT_DIR/bin/generate_map.sh" -w 12 -h 12 -r 35 -o "$MAP_FILE"; then
```
> Calls the external map generator script with:
> - Width = 12
> - Height = 12
> - Obstacle ratio = 35%
> - Output file = `random_map.txt`  
> If it **fails** (non-zero exit), the `if` block executes.

```bash
        show_error "Failed to generate map!"
        return 1
```
> Shows an error and returns failure status.

```bash
    fi
    zenity --info --text="✅ New map generated!" --width=250
```
> On success, shows a success message.

```bash
}
```
> Ends the function.

---

## 4. Function: Run Simple A\* (GUI Output)

```bash
run_astar_simple() {
```
> Begins the `run_astar_simple` function.

```bash
    if [[ ! -f "$MAP_FILE" ]]; then
        show_error "No map file! Generate one first."
        return 1
    fi
```
> Checks if the map file exists. If not, shows error and exits.

```bash
    OUTPUT_FILE="$(mktemp)"
```
> Creates a **temporary file** to capture command output.

```bash
    if ! "$SCRIPT_DIR/bin/run_astar_simple.sh" "$MAP_FILE" > "$OUTPUT_FILE" 2>&1; then
```
> Runs the simple A\* solver, redirecting **stdout and stderr** to the temp file.  
> If the command fails, enters the error-handling block.

```bash
        if grep -q "No path found" "$OUTPUT_FILE"; then
            zenity --info --text="❌ No path found!" --width=250
```
> Special case: if output contains "No path found", show a friendly info message.

```bash
        else
            show_error "A* failed:\n$(cat "$OUTPUT_FILE")"
```
> Otherwise, show full error output in an error dialog.

```bash
        fi
        rm -f "$OUTPUT_FILE"
        return 1
```
> Clean up temp file and return error.

```bash
    fi
```
> End of error check.

```bash
    zenity --text-info --title="A* Result" --filename="$OUTPUT_FILE" --width=500 --height=400
```
> On success, display the A\* output in a scrollable GUI window.

```bash
    rm -f "$OUTPUT_FILE"
```
> Clean up temp file.

```bash
}
```
> End of function.

---

## 5. Function: Run Colored A\* (Terminal Visualization)

```bash
run_astar_colored() {
```
> Begins the colored A\* runner.

```bash
    if [[ ! -f "$MAP_FILE" ]]; then
        show_error "No map file! Generate one first."
        return 1
    fi
```
> Same map existence check as before.

```bash
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "\"$SCRIPT_DIR/bin/run_astar_colored.sh\" \"$MAP_FILE\"; read -p 'Press Enter to close...'"
```
> **Tries `gnome-terminal` first** (common on GNOME).  
> - Runs the colored A\* script  
> - Waits for user to press Enter before closing

```bash
    elif command -v xterm &> /dev/null; then
        xterm -e bash -c "\"$SCRIPT_DIR/bin/run_astar_colored.sh\" \"$MAP_FILE\"; read -p 'Press Enter to close...'"
```
> Falls back to `xterm` (lightweight, widely available)

```bash
    elif command -v konsole &> /dev/null; then
        konsole -e bash -c "\"$SCRIPT_DIR/bin/run_astar_colored.sh\" \"$MAP_FILE\"; read -p 'Press Enter to close...'"
```
> Tries `konsole` (KDE’s terminal)

```bash
    else
        show_error "No terminal found! Install gnome-terminal or xterm."
        return 1
    fi
```
> If **none** of the terminals are installed, show error.

```bash
}
```
> End of function.

---

## 6. Main Menu Loop

```bash
while true; do
```
> Infinite loop – keeps the GUI open until user exits.

```bash
    CHOICE=$(zenity --list \
        --title="A* Pathfinding GUI" \
        --text="Choose an action:" \
        --column="Action" \
        "Generate New Random Map" \
        "Run A* (Simple in GUI)" \
        "Run A* Colored (Terminal)" \
        "View Current Map" \
        "Exit" \
        --width=320 --height=280)
```
> Shows a **list dialog** with 5 options. Returns the selected string.

```bash
    if [[ $? -ne 0 || -z "$CHOICE" ]]; then
        break
    fi
```
> If user **cancels** (e.g., clicks X or Esc), `$? != 0` → exit loop.  
> Also exits if choice is empty.

```bash
    case "$CHOICE" in
```
> Standard `case` statement to handle each menu option.

### Option 1: Generate New Random Map
```bash
        "Generate New Random Map")
            generate_new_map
            ;;
```

### Option 2: Run A\* (Simple in GUI)
```bash
        "Run A* (Simple in GUI)")
            run_astar_simple
            ;;
```

### Option 3: Run A\* Colored (Terminal)
```bash
        "Run A* Colored (Terminal)")
            run_astar_colored
            ;;
```

### Option 4: View Current Map
```bash
        "View Current Map")
            if [[ -f "$MAP_FILE" ]]; then
                zenity --text-info --title="Current Map" --filename="$MAP_FILE" --width=500 --height=400
            else
                show_error "No map file exists yet!"
            fi
            ;;
```
> Opens map in GUI viewer if it exists.

### Option 5: Exit
```bash
        "Exit")
            break
            ;;
```
> Breaks loop → script ends.

### Default: Invalid Choice
```bash
        *)
            show_error "Invalid choice!"
            ;;
```
> Shouldn’t happen with `zenity --list`, but safe to include.

```bash
    esac
done
```
> End of loop.

---