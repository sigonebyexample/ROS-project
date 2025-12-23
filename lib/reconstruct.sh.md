
---

## `reconstruct_path()`

```bash
reconstruct_path() {
    if [[ -f /tmp/astar_came_from ]]; then
        source /tmp/astar_came_from
        rm -f /tmp/astar_came_from
    fi
```

- Checks if a temporary file `/tmp/astar_came_from` exists.  
- If it does, **sources** it (executing its contents in the current shell), which is expected to define associative arrays `CAME_FROM_X` and `CAME_FROM_Y` that record the parent of each visited cell during A\* search.  
- Immediately deletes the temporary file after sourcing.

```bash
    local x=$GOAL_X; local y=$GOAL_Y
```

- Initializes traversal at the goal coordinates (`GOAL_X`, `GOAL_Y`), assumed to be set elsewhere.

```bash
    while ! (( x == START_X && y == START_Y )); do
```

- Loops backward from the goal toward the start, stopping only when both `x` and `y` match the start position (`START_X`, `START_Y`).

```bash
        local key="$x,$y"
        local px=${CAME_FROM_X[$key]}; local py=${CAME_FROM_Y[$key]}
```

- Constructs a string key `"$x,$y"` to look up the parent coordinates in the `CAME_FROM_X` and `CAME_FROM_Y` associative arrays.  
- `px`, `py` store the x and y of the parent cell.

```bash
        [[ -z "$px" ]] && break
```

- If `px` is empty (meaning no parent is recorded for this cell), exits the loop early—this handles cases where the start is unreachable or path data is incomplete.

```bash
        local idx=$(( y * MAP_WIDTH + x ))
        if [[ "${MAP[idx]}" != "@" && "${MAP[idx]}" != "#" ]]; then
            MAP[idx]='*'
        fi
```

- Computes the 1D index `idx` for the current cell `(x, y)` in the flat `MAP` array.  
- If the current cell is **not** the goal (`@`) or start (`#`), replaces its character with `*` to mark it as part of the solution path.

```bash
        x=$px; y=$py
```

- Moves to the parent cell for the next iteration.

```bash
    done
```

- End of path reconstruction loop.

```bash
    for (( y=0; y<MAP_HEIGHT; y++ )); do
        for (( x=0; x<MAP_WIDTH; x++ )); do
            printf '%s' "${MAP[$((y * MAP_WIDTH + x))]}"
        done
        printf '\n'
    done
}
```

- Prints the entire map row by row:  
  - Inner loop prints all characters in a row (left to right).  
  - Outer loop iterates over all rows (top to bottom).  
- The output includes the original walls (`1`), open spaces (`0`), start (`#`), goal (`@`), and the reconstructed path marked with `*`.

---