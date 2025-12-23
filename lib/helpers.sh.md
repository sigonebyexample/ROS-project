
---

# Bash Pathfinding Helper Functions

These functions support grid-based pathfinding logic in a Bash script. They assume the map is stored as a flat array (`MAP`) with known dimensions (`MAP_WIDTH`, `MAP_HEIGHT`).

---

## `heuristic()`

```bash
heuristic() {
    local x1=$1 y1=$2 x2=$3 y2=$4
    local dx=$(( x1 > x2 ? x1 - x2 : x2 - x1 ))
    local dy=$(( y1 > y2 ? y1 - y2 : y2 - y2 ))
    echo $((dx + dy))
}
```

- Accepts four integer arguments: `(x1, y1)` and `(x2, y2)`, representing two grid coordinates.
- Computes `dx` as the absolute difference between `x1` and `x2` using a conditional expression.
- Computes `dy` by comparing `y1` and `y2`; if `y1` is greater, it uses `y1 - y2`, otherwise it uses `y2 - y2`.
- Outputs the sum `dx + dy`, which serves as a distance estimate between the two points.

This function returns a non-negative integer representing a path cost heuristic.

---

## `is_walkable()`

```bash
is_walkable() {
    local x=$1 y=$2
    if (( x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT )); then
        return 1
    fi
    local idx=$(( y * MAP_WIDTH + x ))
    local c="${MAP[idx]}"
    [[ "$c" == "0" || "$c" == "@" || "$c" == "#" ]]
}
```

- Accepts two integer arguments: `x` (column) and `y` (row).
- First checks whether the coordinates are within the valid grid bounds defined by `MAP_WIDTH` and `MAP_HEIGHT`. If not, the function returns `1` (failure).
- Calculates the 1D array index `idx` corresponding to the 2D position `(x, y)` using row-major layout: `index = y * width + x`.
- Retrieves the character `c` at that index from the global array `MAP`.
- Returns success (`0`) if `c` is `"0"`, `"@"`, or `"#"`, indicating the cell is traversable; otherwise, it returns failure (`1`).

The return value follows Bash conventions: `0` means true/walkable, and non-zero means false/not walkable.

---