heuristic() {
    local x1=$1 y1=$2 x2=$3 y2=$4
    local dx=$(( x1 > x2 ? x1 - x2 : x2 - x1 ))
    local dy=$(( y1 > y2 ? y1 - y2 : y2 - y2 ))
    echo $((dx + dy))
}

is_walkable() {
    local x=$1 y=$2
    if (( x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT )); then
        return 1
    fi
    local idx=$(( y * MAP_WIDTH + x ))
    local c="${MAP[idx]}"
    [[ "$c" == "0" || "$c" == "@" || "$c" == "#" ]]
}