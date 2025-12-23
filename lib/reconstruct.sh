reconstruct_path() {
    if [[ -f /tmp/astar_came_from ]]; then
        source /tmp/astar_came_from
        rm -f /tmp/astar_came_from
    fi

    local x=$GOAL_X; local y=$GOAL_Y
    while ! (( x == START_X && y == START_Y )); do
        local key="$x,$y"
        local px=${CAME_FROM_X[$key]}; local py=${CAME_FROM_Y[$key]}
        [[ -z "$px" ]] && break
        local idx=$(( y * MAP_WIDTH + x ))
        if [[ "${MAP[idx]}" != "@" && "${MAP[idx]}" != "#" ]]; then
            MAP[idx]='*'
        fi
        x=$px; y=$py
    done

    for (( y=0; y<MAP_HEIGHT; y++ )); do
        for (( x=0; x<MAP_WIDTH; x++ )); do
            printf '%s' "${MAP[$((y * MAP_WIDTH + x))]}"
        done
        printf '\n'
    done
}