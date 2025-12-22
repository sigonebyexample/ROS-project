find_points() {
    START_X=-1; START_Y=-1
    GOAL_X=-1; GOAL_Y=-1
    for (( y=0; y<MAP_HEIGHT; y++ )); do
        for (( x=0; x<MAP_WIDTH; x++ )); do
            idx=$((y * MAP_WIDTH + x))
            case "${MAP[idx]}" in
                '@') START_X=$x; START_Y=$y ;;
                '#') GOAL_X=$x; GOAL_Y=$y ;;
            esac
        done
    done
    if (( START_X == -1 || GOAL_X == -1 )); then
        echo "Missing @ or #!" >&2
        exit 1
    fi
}
