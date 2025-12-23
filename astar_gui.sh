#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAP_FILE="$SCRIPT_DIR/maps/random_map.txt"

show_error() {
    zenity --error --text="$1" --width=300
}

generate_new_map() {
    if ! "$SCRIPT_DIR/bin/generate_map.sh" -w 12 -h 12 -r 35 -o "$MAP_FILE"; then
        show_error "Failed to generate map!"
        return 1
    fi
    zenity --info --text="✅ New map generated!" --width=250
}

run_astar_simple() {
    if [[ ! -f "$MAP_FILE" ]]; then
        show_error "No map file! Generate one first."
        return 1
    fi

    OUTPUT_FILE="$(mktemp)"
    if ! "$SCRIPT_DIR/bin/run_astar_simple.sh" "$MAP_FILE" > "$OUTPUT_FILE" 2>&1; then
        if grep -q "No path found" "$OUTPUT_FILE"; then
            zenity --info --text="❌ No path found!" --width=250
        else
            show_error "A* failed:\n$(cat "$OUTPUT_FILE")"
        fi
        rm -f "$OUTPUT_FILE"
        return 1
    fi

    zenity --text-info --title="A* Result" --filename="$OUTPUT_FILE" --width=500 --height=400
    rm -f "$OUTPUT_FILE"
}

run_astar_colored() {
    if [[ ! -f "$MAP_FILE" ]]; then
        show_error "No map file! Generate one first."
        return 1
    fi

    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "\"$SCRIPT_DIR/bin/run_astar_colored.sh\" \"$MAP_FILE\"; read -p 'Press Enter to close...'"
    elif command -v xterm &> /dev/null; then
        xterm -e bash -c "\"$SCRIPT_DIR/bin/run_astar_colored.sh\" \"$MAP_FILE\"; read -p 'Press Enter to close...'"
    elif command -v konsole &> /dev/null; then
        konsole -e bash -c "\"$SCRIPT_DIR/bin/run_astar_colored.sh\" \"$MAP_FILE\"; read -p 'Press Enter to close...'"
    else
        show_error "No terminal found! Install gnome-terminal or xterm."
        return 1
    fi
}

while true; do
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

    if [[ $? -ne 0 || -z "$CHOICE" ]]; then
        break
    fi

    case "$CHOICE" in
        "Generate New Random Map")
            generate_new_map
            ;;
        "Run A* (Simple in GUI)")
            run_astar_simple
            ;;
        "Run A* Colored (Terminal)")
            run_astar_colored
            ;;
        "View Current Map")
            if [[ -f "$MAP_FILE" ]]; then
                zenity --text-info --title="Current Map" --filename="$MAP_FILE" --width=500 --height=400
            else
                show_error "No map file exists yet!"
            fi
            ;;
        "Exit")
            break
            ;;
        *)
            show_error "Invalid choice!"
            ;;
    esac
done