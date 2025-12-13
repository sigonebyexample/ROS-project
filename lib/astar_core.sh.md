```markdown
# A* Core Algorithm Implementation

The core A* pathfinding algorithm implementation that performs the actual pathfinding computation using a priority queue simulated with temporary files.

## 📁 File Location
`lib/astar_core.sh`

## 📋 Function Overview

The `run_astar` function implements the complete A* algorithm with the following components:
- Local helper functions (`heuristic`, `is_walkable`)
- Priority queue simulation using temporary files
- A* main loop with path reconstruction capabilities

## 🔍 Line-by-Line Code Explanation

### `run_astar() {`
- **Main function declaration** that encapsulates the entire A* algorithm
- This function is called by `run_astar_simple.sh` after map loading and point detection

### `heuristic() {`
- **Local helper function** that calculates the Manhattan distance heuristic
- Defined inside `run_astar` to avoid namespace conflicts
- Only accessible within the `run_astar` function scope

### `local x1=$1 y1=$2 x2=$3 y2=$4`
- **Parameter assignment** that captures the four coordinates passed to the heuristic function
- `x1,y1` = current position, `x2,y2` = goal position

### `local dx=$(( x1 > x2 ? x1 - x2 : x2 - x1 ))`
- **Absolute difference calculation** for X coordinates using ternary operator
- Computes `|x1 - x2|` without using `abs()` function (not available in Bash)

### `local dy=$(( y1 > y2 ? y1 - y2 : y2 - y2 ))`

### `echo $((dx + dy))`
- **Returns the Manhattan distance** as the heuristic value
- Sum of absolute differences in X and Y coordinates

### `is_walkable() {`
- **Local helper function** that checks if a given coordinate is traversable
- Validates boundaries and checks if the cell is not a wall (`1`)

### `local x=$1 y=$2`
- **Parameter assignment** for the coordinates to check

### `if (( x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT )); then`
- **Boundary check** that ensures coordinates are within map dimensions
- Returns `1` (false) if outside bounds

### `local idx=$(( y * MAP_WIDTH + x ))`
- **2D to 1D array index conversion** 
- Converts `(x,y)` coordinates to linear array index for the `MAP` array

### `local c="${MAP[idx]}"`
- **Retrieves the cell value** at the specified coordinates

### `[[ "$c" == "0" || "$c" == "@" || "$c" == "#" ]]`
- **Walkable cell validation** that returns true (exit code 0) if cell contains:
  - `0` = open path
  - `@` = start position  
  - `#` = goal position

### `declare -A G_SCORE CAME_FROM_X CAME_FROM_Y CLOSED`
- **Associative array declarations** for A* data structures:
  - `G_SCORE`: Actual cost from start to each node
  - `CAME_FROM_X/Y`: Parent coordinates for path reconstruction
  - `CLOSED`: Set of processed nodes

### `OPEN_FILE=$(mktemp)`
- **Creates a temporary file** to simulate a priority queue
- Stores nodes as `f_score,x,y` lines for sorting

### `trap "rm -f $OPEN_FILE" EXIT`
- **Cleanup mechanism** that automatically deletes the temporary file when the script exits
- Prevents temporary file accumulation

### `open_add() { echo "$1,$2,$3" >> "$OPEN_FILE"; }`
- **Priority queue insertion function** that appends nodes as `f,x,y` to the temp file
- Nodes are sorted later when retrieving the minimum

### `open_get_lowest() {`
- **Priority queue extraction function** that retrieves the node with lowest f-score

### `[[ ! -s "$OPEN_FILE" ]] && { echo "-1,-1,-1"; return; }`
- **Empty queue check** that returns sentinel value if no nodes remain

### `local line=$(sort -n "$OPEN_FILE" | head -1)`
- **Finds minimum f-score node** by numerically sorting the temp file and taking the first line

### `grep -v "^$line$" "$OPEN_FILE" > "$OPEN_FILE.tmp" && mv "$OPEN_FILE.tmp" "$OPEN_FILE"`
- **Removes the selected node** from the priority queue
- Creates a new file without the processed line and replaces the original

### `echo "$line"`
- **Returns the extracted node** as `f,x,y` string

### `local h0=$(heuristic $START_X $START_Y $GOAL_X $GOAL_Y)`
- **Initial heuristic calculation** from start to goal

### `G_SCORE["$START_X,$START_Y"]=0`
- **Initializes start node cost** to 0 (no cost to be at start)

### `open_add $h0 $START_X $START_Y`
- **Adds start node to open set** with initial f-score = h0

### `PATH_FOUND=0`
- **Path tracking flag** initialized to false (0)

### `for ((ITER=0; ITER<10000; ITER++)); do`
- **Main A* loop with iteration limit** to prevent infinite loops
- Maximum 10,000 iterations for safety

### `IFS=',' read -r f x y <<< "$(open_get_lowest)"`
- **Extracts the best node** from the priority queue
- Parses `f,x,y` string into separate variables

### `[[ "$x" == "-1" ]] && break`
- **Terminates loop** if queue is empty (sentinel value returned)

### `local key="$x,$y"`
- **Creates coordinate key** for associative array access

### `[[ -n ${CLOSED[$key]+x} ]] && continue`
- **Skip if already processed** - checks if node exists in CLOSED set

### `CLOSED[$key]=1`
- **Mark node as processed** by adding to CLOSED set

### `if (( x == GOAL_X && y == GOAL_Y )); then`
- **Goal check** - terminates algorithm when goal is reached

### `PATH_FOUND=1; break`
- **Sets success flag** and exits the main loop

### `for dir in "0,-1" "0,1" "-1,0" "1,0"; do`
- **Neighbor iteration** for 4-directional movement (up, down, left, right)

### `IFS=',' read -r dx dy <<< "$dir"`
- **Parses direction vector** into dx, dy components

### `local nx=$((x + dx)); local ny=$((y + dy))`
- **Calculates neighbor coordinates** by applying direction vector

### `is_walkable $nx $ny || continue`
- **Skip invalid neighbors** - continues if neighbor is outside bounds or a wall

### `local nkey="$nx,$ny"`
- **Creates neighbor key** for associative array operations

### `[[ -n ${CLOSED[$nkey]+x} ]] && continue`
- **Skip processed neighbors** - continues if neighbor already in CLOSED set

### `local tentative_g=$(( ${G_SCORE[$key]} + 1 ))`
- **Calculates tentative G score** for neighbor (current cost + 1)

### `if [[ -z ${G_SCORE[$nkey]+x} ]] || (( tentative_g < ${G_SCORE[$nkey]} )); then`
- **Path improvement check** - updates if this is first visit or better path found

### `CAME_FROM_X[$nkey]=$x; CAME_FROM_Y[$nkey]=$y`
- **Records parent coordinates** for path reconstruction

### `G_SCORE[$nkey]=$tentative_g`
- **Updates neighbor's G score** with the better cost

### `local h=$(heuristic $nx $ny $GOAL_X $GOAL_Y)`
- **Calculates heuristic** from neighbor to goal

### `open_add $((tentative_g + h)) $nx $ny`
- **Adds neighbor to open set** with f-score = g + h

### `if (( PATH_FOUND == 0 )); then`
- **No path handling** - executes if goal was never reached

### `echo "No path found!" >&2; exit 1`
- **Error output** to stderr and exits with error code

### `declare -p CAME_FROM_X CAME_FROM_Y > /tmp/astar_came_from 2>/dev/null`
- **Exports path data** by serializing the parent arrays to a temporary file
- Allows other scripts to reconstruct the path

### `export PATH_FOUND=1`
- **Exports success flag** to parent shell environment