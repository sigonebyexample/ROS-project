
---

## `read_map()`

```bash
read_map() {
    MAP=()
    MAP_HEIGHT=0
    MAP_WIDTH=0
    local MAPFILE="$1"
```

- Initializes global variables:  
  - `MAP` as an empty array to store the map characters.  
  - `MAP_HEIGHT` and `MAP_WIDTH` as zero.  
- Stores the first argument (`$1`) in a local variable `MAPFILE`, expected to be the path to a map text file.

```bash
    while IFS= read -r line; do
```

- Reads the file line by line.  
- `IFS=` preserves leading/trailing whitespace.  
- `-r` disables backslash escaping.

```bash
        line="${line%%$'\r'}"
```

- Strips any trailing carriage return (`\r`) from the line, supporting files with Windows-style line endings.

```bash
        [[ -z "$line" ]] && continue
```

- Skips empty lines.

```bash
        if (( MAP_HEIGHT == 0 )); then
            MAP_WIDTH=${#line}
```

- On the first non-empty line (when `MAP_HEIGHT` is still 0), sets `MAP_WIDTH` to the number of characters in that line.

```bash
        elif (( ${#line} != MAP_WIDTH )); then
            echo "Inconsistent width!" >&2
            exit 1
        fi
```

- For all subsequent lines, checks that the line length matches `MAP_WIDTH`.  
- If not, prints an error to standard error and exits the script with code 1.

```bash
        for (( i=0; i<MAP_WIDTH; i++ )); do
            MAP+=("${line:i:1}")
        done
```

- Iterates over each character position `i` in the current line.  
- Extracts one character at position `i` using `${line:i:1}` and appends it to the `MAP` array.

```bash
        ((MAP_HEIGHT++))
    done < "$MAPFILE"
}
```

- Increments `MAP_HEIGHT` after processing each valid line.  
- The entire loop reads from the file specified by `MAPFILE`.

---

### Result

After execution:
- `MAP` contains all characters from the map file in **row-major order** (left to right, top to bottom).
- `MAP_WIDTH` holds the number of columns.
- `MAP_HEIGHT` holds the number of rows.  

The function ensures the input map is a **rectangular grid** with consistent row lengths.