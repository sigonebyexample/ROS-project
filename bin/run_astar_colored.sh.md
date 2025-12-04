# A* Pathfinding Visualizer Script Documentation

## Overview
This Bash script implements the A* pathfinding algorithm with real-time visualization. It finds the shortest path between start (`@`) and goal (`#`) positions on a grid map, displaying the search process step by step.

## Complete Script

```bash
#!/bin/bash

MAPFILE="$1"
[[ ! -f "$MAPFILE" ]] && { echo "File not found!"; exit 1; }


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/read_map.sh"
source "$SCRIPT_DIR/lib/find_points.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
read_map "$MAPFILE"
find_points


GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
WHITE='\033[0m'
BLACK='\033[0;30m'

declare -A G_SCORE CAME_FROM_X CAME_FROM_Y CLOSED
OPEN_FILE=$(mktemp)
trap "rm -f $OPEN_FILE; tput cnorm" EXIT

open_add() { echo "$1,$2,$3" >> "$OPEN_FILE"; }
open_get_lowest() {
    [[ ! -s "$OPEN_FILE" ]] && { echo "-1,-1,-1"; return; }
    local line=$(sort -n "$OPEN_FILE" | head -1)
    grep -v "^$line$" "$OPEN_FILE" > "$OPEN_FILE.tmp" && mv "$OPEN_FILE.tmp" "$OPEN_FILE"
    echo "$line"
}

h0=$(heuristic $START_X $START_Y $GOAL_X $GOAL_Y)
G_SCORE["$START_X,$START_Y"]=0
open_add $h0 $START_X $START_Y

PATH_FOUND=0

clear
tput civis  

while true; do
    IFS=',' read -r f x y <<< "$(open_get_lowest)"
    [[ "$x" == "-1" ]] && break

    key="$x,$y"
    [[ -n ${CLOSED[$key]+x} ]] && continue
    CLOSED[$key]=1

   
    clear
    for (( yy=0; yy<MAP_HEIGHT; yy++ )); do
        for (( xx=0; xx<MAP_WIDTH; xx++ )); do
            idx=$((yy * MAP_WIDTH + xx))
            char="${MAP[idx]}"
           
            if [[ -n ${CLOSED["$xx,$yy"]+x} ]]; then
                if [[ "$char" != "@" && "$char" != "#" ]]; then
                    char="o"
                fi
            fi
            
            if (( xx == x && yy == y )) && [[ "$char" != "@" && "$char" != "#" ]]; then
                char="+"
            fi

            case "$char" in
                '@') echo -ne "${GREEN}@${WHITE}" ;;
                '#') echo -ne "${RED}#${WHITE}" ;;
                'o'|'+') echo -ne "${GRAY}$char${WHITE}" ;;
                '1') echo -ne "${BLACK}1${WHITE}" ;;
                '0') echo -ne "0" ;;
                '*') echo -ne "${BLUE}*${WHITE}" ;;
                *) echo -ne "$char" ;;
            esac
        done
        echo
    done
    printf "\n🔍 Processing node: (%d, %d)\n" $x $y
    sleep 0.3

    if (( x == GOAL_X && y == GOAL_Y )); then
        PATH_FOUND=1
        break
    fi

    for dir in "0,-1" "0,1" "-1,0" "1,0"; do
        IFS=',' read -r dx dy <<< "$dir"
        nx=$((x + dx)); ny=$((y + dy))
        is_walkable $nx $ny || continue
        nkey="$nx,$ny"
        [[ -n ${CLOSED[$nkey]+x} ]] && continue

        tentative_g=$(( ${G_SCORE[$key]} + 1 ))
        if [[ -z ${G_SCORE[$nkey]+x} ]] || (( tentative_g < ${G_SCORE[$nkey]} )); then
            CAME_FROM_X[$nkey]=$x
            CAME_FROM_Y[$nkey]=$y
            G_SCORE[$nkey]=$tentative_g
            h=$(heuristic $nx $ny $GOAL_X $GOAL_Y)
            open_add $((tentative_g + h)) $nx $ny
        fi
    done
done

tput cnorm   

if (( PATH_FOUND == 0 )); then
    echo -e "\n${RED}❌ No path found!${WHITE}"
    exit 1
fi


x=$GOAL_X; y=$GOAL_Y
while ! (( x == START_X && y == START_Y )); do
    key="$x,$y"
    px=${CAME_FROM_X[$key]}; py=${CAME_FROM_Y[$key]}
    [[ -z "$px" ]] && break
    idx=$(( y * MAP_WIDTH + x ))
    if [[ "${MAP[idx]}" != "@" && "${MAP[idx]}" != "#" ]]; then
        MAP[idx]='*'
    fi
    x=$px; y=$py
done

clear
echo -e "${GREEN}✅ Final Path:${WHITE}"
for (( y=0; y<MAP_HEIGHT; y++ )); do
    for (( x=0; x<MAP_WIDTH; x++ )); do
        idx=$((y * MAP_WIDTH + x))
        char="${MAP[idx]}"
        case "$char" in
            '@') echo -ne "${GREEN}@${WHITE}" ;;
            '#') echo -ne "${RED}#${WHITE}" ;;
            '*') echo -ne "${BLUE}*${WHITE}" ;;
            '1') echo -ne "${BLACK}1${WHITE}" ;;
            *) echo -ne "$char" ;;
        esac
    done
    echo
done
```

## Detailed Line-by-Line Explanation

### Script Initialization and File Check
```bash
#!/bin/bash
```
**Shebang**: Specifies that the script should be executed using the Bash shell.

```bash
MAPFILE="$1"
[[ ! -f "$MAPFILE" ]] && { echo "File not found!"; exit 1; }
```
**Line 3**: Stores the first command-line argument as `MAPFILE`.  
**Line 4**: Checks if the file exists. If not, prints error and exits with code 1.

### Module Loading
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/read_map.sh"
source "$SCRIPT_DIR/lib/find_points.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
read_map "$MAPFILE"
find_points
```
**Line 7**: Calculates the script directory (going up one level from the script location).  
**Lines 8-10**: Loads external modules for map reading, point finding, and helper functions.  
**Lines 11-12**: Calls functions to read the map file and locate start/goal positions.

### ANSI Color Definitions
```bash
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
WHITE='\033[0m'
BLACK='\033[0;30m'
```
**Lines 15-20**: Defines ANSI escape codes for colored terminal output. These colors are used for visualization.

### Data Structures Initialization
```bash
declare -A G_SCORE CAME_FROM_X CAME_FROM_Y CLOSED
```
**Line 22**: Declares associative arrays for A* algorithm:
- `G_SCORE`: Stores the cost from start to each node
- `CAME_FROM_X/CAME_FROM_Y`: Store parent nodes for path reconstruction
- `CLOSED`: Tracks visited nodes

### Open Set Management (Priority Queue)
```bash
OPEN_FILE=$(mktemp)
trap "rm -f $OPEN_FILE; tput cnorm" EXIT
```
**Line 23**: Creates a temporary file to act as a priority queue for the open set.  
**Line 24**: Sets up a trap to clean up the temp file and restore cursor visibility on script exit.

```bash
open_add() { echo "$1,$2,$3" >> "$OPEN_FILE"; }
```
**Line 26**: Defines a function to add nodes to the open set. Format: `f_score,x,y`.

```bash
open_get_lowest() {
    [[ ! -s "$OPEN_FILE" ]] && { echo "-1,-1,-1"; return; }
    local line=$(sort -n "$OPEN_FILE" | head -1)
    grep -v "^$line$" "$OPEN_FILE" > "$OPEN_FILE.tmp" && mv "$OPEN_FILE.tmp" "$OPEN_FILE"
    echo "$line"
}
```
**Lines 27-33**: Function to get the node with the lowest f-score from the open set:
- **Line 28**: Returns `-1,-1,-1` if the open set is empty
- **Line 29**: Sorts the file numerically and takes the first line (lowest f-score)
- **Line 30-31**: Removes the selected line from the file
- **Line 32**: Returns the selected node

### A* Algorithm Initialization
```bash
h0=$(heuristic $START_X $START_Y $GOAL_X $GOAL_Y)
G_SCORE["$START_X,$START_Y"]=0
open_add $h0 $START_X $START_Y

PATH_FOUND=0
```
**Line 35**: Calculates heuristic (Manhattan distance) from start to goal.  
**Line 36**: Sets g-score of start node to 0.  
**Line 37**: Adds start node to open set with f-score = h-score.  
**Line 39**: Initializes path found flag to false.

### Terminal Setup
```bash
clear
tput civis  
```
**Line 41**: Clears the terminal screen.  
**Line 42**: Hides the cursor for cleaner animation.

### Main A* Loop
```bash
while true; do
    IFS=',' read -r f x y <<< "$(open_get_lowest)"
    [[ "$x" == "-1" ]] && break

    key="$x,$y"
    [[ -n ${CLOSED[$key]+x} ]] && continue
    CLOSED[$key]=1
```
**Line 44**: Starts infinite loop for A* search.  
**Line 45**: Gets the node with lowest f-score from open set, splits into variables.  
**Line 46**: Breaks if open set is empty (no path).  
**Line 48**: Creates a key string for the current node.  
**Line 49**: Skips if node already in closed set.  
**Line 50**: Adds node to closed set.

### Real-time Map Visualization
```bash
    clear
    for (( yy=0; yy<MAP_HEIGHT; yy++ )); do
        for (( xx=0; xx<MAP_WIDTH; xx++ )); do
            idx=$((yy * MAP_WIDTH + xx))
            char="${MAP[idx]}"
            # بررسی closed
            if [[ -n ${CLOSED["$xx,$yy"]+x} ]]; then
                if [[ "$char" != "@" && "$char" != "#" ]]; then
                    char="o"
                fi
            fi
            # بررسی گره فعلی
            if (( xx == x && yy == y )) && [[ "$char" != "@" && "$char" != "#" ]]; then
                char="+"
            fi

            case "$char" in
                '@') echo -ne "${GREEN}@${WHITE}" ;;
                '#') echo -ne "${RED}#${WHITE}" ;;
                'o'|'+') echo -ne "${GRAY}$char${WHITE}" ;;
                '1') echo -ne "${BLACK}1${WHITE}" ;;
                '0') echo -ne "0" ;;
                '*') echo -ne "${BLUE}*${WHITE}" ;;
                *) echo -ne "$char" ;;
            esac
        done
        echo
    done
    printf "\n🔍 Processing node: (%d, %d)\n" $x $y
    sleep 0.3
```
**Lines 53-78**: Displays the current state of the search:
- **Lines 54-57**: Loops through all map cells
- **Lines 59-63**: Marks visited nodes (in closed set) with `o`
- **Lines 65-67**: Marks current processing node with `+`
- **Lines 70-76**: Applies colors to different cell types
- **Line 77**: Prints coordinates of current node
- **Line 78**: Pauses for 0.3 seconds for visualization

### Goal Check
```bash
    if (( x == GOAL_X && y == GOAL_Y )); then
        PATH_FOUND=1
        break
    fi
```
**Lines 80-83**: Checks if current node is the goal. If yes, sets flag and breaks loop.

### Neighbor Processing
```bash
    for dir in "0,-1" "0,1" "-1,0" "1,0"; do
        IFS=',' read -r dx dy <<< "$dir"
        nx=$((x + dx)); ny=$((y + dy))
        is_walkable $nx $ny || continue
        nkey="$nx,$ny"
        [[ -n ${CLOSED[$nkey]+x} ]] && continue

        tentative_g=$(( ${G_SCORE[$key]} + 1 ))
        if [[ -z ${G_SCORE[$nkey]+x} ]] || (( tentative_g < ${G_SCORE[$nkey]} )); then
            CAME_FROM_X[$nkey]=$x
            CAME_FROM_Y[$nkey]=$y
            G_SCORE[$nkey]=$tentative_g
            h=$(heuristic $nx $ny $GOAL_X $GOAL_Y)
            open_add $((tentative_g + h)) $nx $ny
        fi
    done
done
```
**Lines 85-100**: Processes all four neighboring nodes (up, down, left, right):
- **Line 85**: Loops through four directions
- **Line 86**: Splits direction into dx, dy components
- **Line 87**: Calculates neighbor coordinates
- **Line 88**: Checks if neighbor is walkable (not a wall)
- **Line 89**: Creates key for neighbor
- **Line 90**: Skips if neighbor already in closed set
- **Line 92**: Calculates tentative g-score (current g + 1)
- **Lines 93-98**: If this is a better path to neighbor:
  - **Lines 94-95**: Records parent node
  - **Line 96**: Updates g-score
  - **Line 97**: Calculates heuristic for neighbor
  - **Line 98**: Adds neighbor to open set with f-score = g + h

### Terminal Cleanup
```bash
tput cnorm  
```
**Line 102**: Restores cursor visibility.

### Path Not Found Handling
```bash
if (( PATH_FOUND == 0 )); then
    echo -e "\n${RED}❌ No path found!${WHITE}"
    exit 1
fi
```
**Lines 104-107**: If path not found, displays error message and exits.

### Path Reconstruction
```bash
x=$GOAL_X; y=$GOAL_Y
while ! (( x == START_X && y == START_Y )); do
    key="$x,$y"
    px=${CAME_FROM_X[$key]}; py=${CAME_FROM_Y[$key]}
    [[ -z "$px" ]] && break
    idx=$(( y * MAP_WIDTH + x ))
    if [[ "${MAP[idx]}" != "@" && "${MAP[idx]}" != "#" ]]; then
        MAP[idx]='*'
    fi
    x=$px; y=$py
done
```
**Lines 110-119**: Reconstructs the path from goal to start:
- **Line 110**: Starts from goal position
- **Line 111**: Continues until reaching start
- **Line 112**: Creates key for current node
- **Line 113**: Gets parent coordinates
- **Line 114**: Breaks if no parent (shouldn't happen)
- **Line 115**: Calculates map index
- **Lines 116-118**: Marks path with `*` (except start and goal)
- **Line 119**: Moves to parent node

### Final Path Display
```bash
clear
echo -e "${GREEN}✅ Final Path:${WHITE}"
for (( y=0; y<MAP_HEIGHT; y++ )); do
    for (( x=0; x<MAP_WIDTH; x++ )); do
        idx=$((y * MAP_WIDTH + x))
        char="${MAP[idx]}"
        case "$char" in
            '@') echo -ne "${GREEN}@${WHITE}" ;;
            '#') echo -ne "${RED}#${WHITE}" ;;
            '*') echo -ne "${BLUE}*${WHITE}" ;;
            '1') echo -ne "${BLACK}1${WHITE}" ;;
            *) echo -ne "$char" ;;
        esac
    done
    echo
done
```
**Lines 122-136**: Displays the final path:
- **Line 122**: Clears screen
- **Line 123**: Shows success message
- **Lines 124-135**: Prints the complete map with the found path highlighted in blue

## Key Features

### 1. **A* Algorithm Implementation**
- Uses Manhattan distance heuristic
- Maintains open set (frontier) as priority queue
- Tracks g-scores (cost from start) and parent nodes

### 2. **Real-time Visualization**
- Shows search process step by step
- Uses different symbols for:
  - `@`: Start position (green)
  - `#`: Goal position (red)
  - `o`: Visited nodes (gray)
  - `+`: Currently processing node (gray)
  - `*`: Final path (blue)
  - `1`: Walls (black)
  - `0`: Walkable floor (white)

### 3. **Error Handling**
- Validates input file existence
- Handles no-path scenarios
- Cleans up temporary files on exit

### 4. **Terminal Control**
- Hides/shows cursor for clean display
- Clears screen between frames
- Controls animation speed with `sleep`

## Usage Example

```bash
# Generate a random map first
./random_map.sh -w 15 -h 10 -r 20 -o my_map.txt

# Run A* pathfinding on the map
./astar.sh my_map.txt
```

## Dependencies

The script requires these external modules (loaded via `source`):
- `read_map.sh`: Reads map file into memory
- `find_points.sh`: Locates start (`@`) and goal (`#`) positions
- `helpers.sh`: Contains `heuristic()` and `is_walkable()` functions

## Algorithm Complexity

- **Time**: O(b^d) where b is branching factor (max 4) and d is path depth
- **Space**: O(n) for storing scores and parent pointers
- **Optimal**: Yes, with admissible heuristic (Manhattan distance)

## Color Legend

| Symbol | Color | Meaning                   |
|--------|-------|---------------------------|
| `@`    | Green | Start position            |
| `#`    | Red   | Goal position             |
| `*`    | Blue  | Final path                |
| `o`    | Gray  | Visited nodes             |
| `+`    | Gray  | Currently processing node |
| `1`    | Black | Wall/obstacle             |
| `0`    | White | Walkable floor            |