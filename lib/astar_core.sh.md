run_astar() {
    # Source helpers for internal functions
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

    declare -A G_SCORE CAME_FROM_X CAME_FROM_Y CLOSED
    OPEN_FILE=$(mktemp)
    trap "rm -f $OPEN_FILE" EXIT

    open_add() { echo "$1,$2,$3" >> "$OPEN_FILE"; }
    open_get_lowest() {
        [[ ! -s "$OPEN_FILE" ]] && { echo "-1,-1,-1"; return; }
        local line=$(sort -n "$OPEN_FILE" | head -1)
        grep -v "^$line$" "$OPEN_FILE" > "$OPEN_FILE.tmp" && mv "$OPEN_FILE.tmp" "$OPEN_FILE"
        echo "$line"
    }

    local h0=$(heuristic $START_X $START_Y $GOAL_X $GOAL_Y)
    G_SCORE["$START_X,$START_Y"]=0
    open_add $h0 $START_X $START_Y

    PATH_FOUND=0
    for ((ITER=0; ITER<10000; ITER++)); do
        IFS=',' read -r f x y <<< "$(open_get_lowest)"
        [[ "$x" == "-1" ]] && break
        local key="$x,$y"
        [[ -n ${CLOSED[$key]+x} ]] && continue
        CLOSED[$key]=1

        if (( x == GOAL_X && y == GOAL_Y )); then
            PATH_FOUND=1
            break
        fi

        for dir in "0,-1" "0,1" "-1,0" "1,0"; do
            IFS=',' read -r dx dy <<< "$dir"
            local nx=$((x + dx)); local ny=$((y + dy))
            is_walkable $nx $ny || continue
            local nkey="$nx,$ny"
            [[ -n ${CLOSED[$nkey]+x} ]] && continue

            local tentative_g=$(( ${G_SCORE[$key]} + 1 ))
            if [[ -z ${G_SCORE[$nkey]+x} ]] || (( tentative_g < ${G_SCORE[$nkey]} )); then
                CAME_FROM_X[$nkey]=$x
                CAME_FROM_Y[$nkey]=$y
                G_SCORE[$nkey]=$tentative_g
                local h=$(heuristic $nx $ny $GOAL_X $GOAL_Y)
                open_add $((tentative_g + h)) $nx $ny
            fi
        done
    done

    if (( PATH_FOUND == 0 )); then
        echo "No path found!" >&2
        exit 1
    fi

    declare -p CAME_FROM_X CAME_FROM_Y > /tmp/astar_came_from 2>/dev/null
    export PATH_FOUND=1
}