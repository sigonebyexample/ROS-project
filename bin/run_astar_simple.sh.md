

```markdown
# A\* Pathfinding Script

This Bash script implements the A\* pathfinding algorithm to find and visualize the shortest path between a start point (`@`) and a goal point (`#`) in a text-based map.

## Usage

```bash
./astar.sh <mapfile>
```

**Example:**
```bash
./astar.sh maps/mymap.txt
```

## How It Works

1. **Input Validation**  
   The script checks that the provided map file exists. If not, it exits with an error:
   ```
   File not found!
   ```

2. **Project Structure Awareness**  
   The script automatically determines the project root directory, allowing it to reliably source helper libraries regardless of where it's executed from.

3. **Modular Design**  
   Functionality is split across reusable library scripts:

   - `lib/read_map.sh` — Reads and parses the map file into a grid.
   - `lib/find_points.sh` — Locates the start (`@`) and goal (`#`) coordinates.
   - `lib/astar_core.sh` — Implements the A\* pathfinding algorithm.
   - `lib/reconstruct.sh` — Reconstructs and displays the shortest path using `*` characters.

4. **Output**  
   The final map is printed to standard output with the computed path marked by `*`, connecting `@` to `#`.

## Map Format

Your map file should be a plain text grid using the following symbols:

- `@` — Start position  
- `#` — Goal position  
- `.` — Traversable space  
- `#` or any non-`.` character (other than `@`/`#`) — Obstacle (impassable)

**Example map (`mymap.txt`):**
```
#######
#.....#
#@...##
#.#...#
#...#.#
##...##
#....##
#######
```

## Requirements

- Bash (v4.0 or higher recommended for associative arrays)
- Unix-like system (Linux, macOS, WSL, etc.)