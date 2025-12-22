```bash
find_points() {
```
- This starts the definition of a Bash function named `find_points`.

```bash
    START_X=-1; START_Y=-1
```
- Initializes the variables `START_X` and `START_Y` to -1. These will later store the coordinates of the start point (`@`).

```bash
    GOAL_X=-1; GOAL_Y=-1
```
- Similarly initializes `GOAL_X` and `GOAL_Y` to -1. These will store the coordinates of the goal point (`#`).

```bash
    for (( y=0; y<MAP_HEIGHT; y++ )); do
```
- Begins a loop over the rows (`y` coordinate) of a 2D map. `MAP_HEIGHT` is assumed to be a previously defined variable indicating how many rows the map has.

```bash
        for (( x=0; x<MAP_WIDTH; x++ )); do
```
- Begins a nested loop over the columns (`x` coordinate) of the map. `MAP_WIDTH` is assumed to be a previously defined variable indicating how many columns each row has.

```bash
            idx=$((y * MAP_WIDTH + x))
```
- Calculates a linear index `idx` into a flat (1D) array `MAP` that represents a 2D grid. This is standard row-major indexing: row `y`, column `x`.

```bash
            case "${MAP[idx]}" in
```
- Starts a `case` statement to check the character stored in the `MAP` array at index `idx`.

```bash
                '@') START_X=$x; START_Y=$y ;;
```
- If the character is `'@'`, it marks the start position, so we record the current `x` and `y` into `START_X` and `START_Y`.

```bash
                '#') GOAL_X=$x; GOAL_Y=$y ;;
```
- If the character is `'#'`, it marks the goal position, so we record the current `x` and `y` into `GOAL_X` and `GOAL_Y`.

```bash
            esac
```
- Ends the `case` statement.

```bash
        done
```
- Ends the inner loop (over `x`).

```bash
    done
```
- Ends the outer loop (over `y`).

```bash
    if (( START_X == -1 || GOAL_X == -1 )); then
```
- After scanning the entire map, checks whether either the start (`@`) or goal (`#`) was not found (i.e., their coordinates are still -1).

```bash
        echo "Missing @ or #!" >&2
```
- If either is missing, prints an error message to standard error (`>&2`).

```bash
        exit 1
```
- Exits the script with status code 1, indicating an error.

```bash
    fi
```
- Ends the `if` block.

```bash
}
```
- Ends the function definition.
