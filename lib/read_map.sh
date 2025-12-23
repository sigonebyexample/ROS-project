read_map() {
    MAP=()
    MAP_HEIGHT=0
    MAP_WIDTH=0
    local MAPFILE="$1"
    while IFS= read -r line; do
        line="${line%%$'\r'}"
        [[ -z "$line" ]] && continue
        if (( MAP_HEIGHT == 0 )); then
            MAP_WIDTH=${#line}
        elif (( ${#line} != MAP_WIDTH )); then
            echo "Inconsistent width!" >&2
            exit 1
        fi
        for (( i=0; i<MAP_WIDTH; i++ )); do
            MAP+=("${line:i:1}")
        done
        ((MAP_HEIGHT++))
    done < "$MAPFILE"
}