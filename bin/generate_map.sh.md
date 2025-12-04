# Random Map Generator — Line-by-Line Explanation

This document provides a detailed, line-by-line breakdown of the Bash script that generates a random grid-based map with walls (`1`), open space (`0`), a start (`@`), and a goal (`#`). The map always includes a guaranteed path from start to goal.

---

## Full Script with Annotations

```bash
#!/bin/bash
```
- **Shebang line**: Tells the system to run this script using the Bash shell.

```bash
WIDTH=10
```
- Default map width (number of columns). Can be changed via `-w` or `--width`.

```bash
HEIGHT=10
```
- Default map height (number of rows). Changed with `-h` or `--height`.

```bash
WALL_RATIO=30
```
- Percentage (0–100) chance that an interior open cell becomes a wall. Set via `-r` or `--ratio`.

```bash
OUTPUT="random_map.txt"
```
- Default output filename. Customizable with `-o` or `--output`.

```bash
while [[ $# -gt 0 ]]; do
```
- Begin a loop to process all command-line arguments (`$#` is the number of remaining arguments).

```bash
    case $1 in
```
- Start a `case` statement to match the current first argument (`$1`).

```bash
        -w|--width) WIDTH="$2"; shift 2 ;;
```
- If the argument is `-w` or `--width`, set `WIDTH` to the next argument (`$2`), then skip both arguments using `shift 2`.

```bash
        -h|--height) HEIGHT="$2"; shift 2 ;;
```
- Same logic for height.

```bash
        -r|--ratio) WALL_RATIO="$2"; shift 2 ;;
```
- Same for wall ratio.

```bash
        -o|--output) OUTPUT="$2"; shift 2 ;;
```
- Same for output file.

```bash
        *) echo "Unknown option: $1"; exit 1 ;;
```
- If the option is unrecognized, print an error to **standard error** and exit with failure code `1`.

```bash
    esac
```
- End the `case` block.

```bash
done
```
- End the argument-parsing loop.

```bash
if (( WIDTH < 3 || HEIGHT < 3 )); then
```
- Validate that both dimensions are at least 3 (needed for borders + interior space).

```bash
    echo "Error: Width and height must be at least 3!" >&2
```
- Print error message to **stderr** (using `>&2`).

```bash
    exit 1
```
- Terminate script with error status.

```bash
fi
```
- End the width/height validation block.

```bash
if (( WALL_RATIO < 0 || WALL_RATIO > 100 )); then
```
- Ensure wall ratio is a valid percentage.

```bash
    echo "Error: Wall ratio must be between 0 and 100!" >&2
    exit 1
fi
```
- Error and exit if out of range.

```bash
declare -A GRID
```
- Declare `GRID` as an **associative array** to store the 2D map (using keys like `y,x`).

```bash
for (( y=0; y<HEIGHT; y++ )); do
    for (( x=0; x<WIDTH; x++ )); do
        GRID[$y,$x]="0"
    done
done
```
- Initialize every cell in the grid to `"0"` (walkable floor).

```bash
for (( x=0; x<WIDTH; x++ )); do
    GRID[0,$x]="1"
    GRID[$((HEIGHT-1)),$x]="1"
done
```
- Set the **top row** (`y=0`) and **bottom row** (`y=HEIGHT-1`) to walls (`"1"`).

```bash
for (( y=0; y<HEIGHT; y++ )); do
    GRID[$y,0]="1"
    GRID[$y,$((WIDTH-1))]="1"
done
```
- Set the **leftmost column** (`x=0`) and **rightmost column** (`x=WIDTH-1`) to walls.

```bash
START_X=$(( RANDOM % (WIDTH - 2) + 1 ))
START_Y=$(( RANDOM % (HEIGHT - 2) + 1 ))
GOAL_X=$(( RANDOM % (WIDTH - 2) + 1 ))
GOAL_Y=$(( RANDOM % (HEIGHT - 2) + 1 ))
```
- Randomly choose **interior positions** for start and goal (never on borders).  
  `RANDOM % (N-2) + 1` gives values in `[1, N-2]`.

```bash
while (( START_X == GOAL_X && START_Y == GOAL_Y )); do
    GOAL_X=$(( RANDOM % (WIDTH - 2) + 1 ))
    GOAL_Y=$(( RANDOM % (HEIGHT - 2) + 1 ))
done
```
- Ensure start and goal are **not in the same cell** by re-rolling the goal if needed.

```bash
x=$START_X
y=$START_Y
```
- Initialize current position to the start for path carving.

```bash
while (( x != GOAL_X )); do
    if (( x < GOAL_X )); then ((x++)); else ((x--)); fi
    GRID[$y,$x]="0"
done
```
- Move **horizontally** from start to the goal’s x-coordinate, setting each cell to `"0"` (ensuring a clear path).

```bash
while (( y != GOAL_Y )); do
    if (( y < GOAL_Y )); then ((y++)); else ((y--)); fi
    GRID[$y,$x]="0"
done
```
- Move **vertically** from current y to goal’s y, again clearing the path.  
  Together, this creates an **L-shaped guaranteed path**.

```bash
GRID[$START_Y,$START_X]="@"
```
- Place the **start symbol** (`@`) on the grid.

```bash
GRID[$GOAL_Y,$GOAL_X]="#"
```
- Place the **goal symbol** (`#`) on the grid.

```bash
for (( y=1; y<HEIGHT-1; y++ )); do
    for (( x=1; x<WIDTH-1; x++ )); do
```
- Loop over all **interior cells only** (excluding borders).

```bash
        if [[ "${GRID[$y,$x]}" == "0" ]]; then
```
- Only consider cells that are currently **open floor** (`"0"`).

```bash
            if (( RANDOM % 100 < WALL_RATIO )); then
```
- With probability `WALL_RATIO%`, attempt to convert this cell to a wall.

```bash
                is_adjacent=0
```
- Initialize a flag to check if the cell is adjacent to start or goal.

```bash
                for dy in -1 0 1; do
                    for dx in -1 0 1; do
```
- Check all **8 neighboring positions** (Moore neighborhood: includes diagonals).

```bash
                        if (( dx == 0 && dy == 0 )); then continue; fi
```
- Skip the center (the cell itself); only check neighbors.

```bash
                        if (( x == START_X + dx && y == START_Y + dy )) || (( x == GOAL_X + dx && y == GOAL_Y + dy )); then
                            is_adjacent=1
                        fi
```
- If `(x,y)` matches any neighbor of the start **or** goal, mark it as adjacent.

```bash
                    done
                done
```
- End neighbor-checking loops.

```bash
                if (( is_adjacent == 0 )); then
                    GRID[$y,$x]="1"
                fi
```
- Only place a wall if the cell is **not adjacent** to `@` or `#`, ensuring they remain accessible.

```bash
            fi
        fi
    done
done
```
- End interior cell processing.

```bash
{
    for (( y=0; y<HEIGHT; y++ )); do
        for (( x=0; x<WIDTH; x++ )); do
            printf '%s' "${GRID[$y,$x]}"
        done
        printf '\n'
    done
} > "$OUTPUT"
```
- Output the entire grid to the file specified by `OUTPUT`:  
  - Each row is printed as a string of characters (`0`, `1`, `@`, `#`).  
  - A newline is added after each row.  
  - The `{ ... }` block ensures all output is redirected together.

```bash
echo "✅ Random map generated: $OUTPUT" >&2
echo "   Size: ${WIDTH}x${HEIGHT}" >&2
echo "   Wall ratio: ${WALL_RATIO}%" >&2
```
- Print a success message with map details to **standard error**, so it doesn’t interfere with file output or piping.

---

## Map Legend

| Symbol | Meaning               |
|--------|-----------------------|
| `1`    | Wall (impassable)     |
| `0`    | Open floor (walkable) |
| `@`    | Start position        |
| `#`    | Goal position         |

## Key Features

- **Always solvable**: An L-shaped path guarantees connectivity.
- **Borders are solid walls**.
- **Random walls avoid** cells next to start/goal.
- Fully **configurable via command-line arguments**.

## Example Usage

```bash
./generate_map.sh -w 15 -h 12 -r 40 -o my_map.txt
```

Generates a 15×12 map with 40% interior wall density, saved to `my_map.txt`.
```