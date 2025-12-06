#!/bin/bash

MAPFILE="$1"
[[ ! -f "$MAPFILE" ]] && { echo "File not found!"; exit 1; }

MAP=()
MAP_HEIGHT=0
MAP_WIDTH=0

while IFS= read -r line; do
    line="${line%%$'\r'}"
    [[ -z "$line" ]] && continue
    if (( MAP_HEIGHT == 0 )); then
        MAP_WIDTH=${#line}
    elif (( ${#line} != MAP_WIDTH )); then
        echo "Inconsistent width!" >&2; exit 1
    fi
    for (( i=0; i<MAP_WIDTH; i++ )); do
        MAP+=("${line:i:1}")
    done
    ((MAP_HEIGHT++))
done < "$MAPFILE"

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

[[ $START_X -eq -1 || $GOAL_X -eq -1 ]] && { echo "Missing @ or #!" >&2; exit 1; }

heuristic() {
    local dx=$(( $1 > $3 ? $1 - $3 : $3 - $1 ))
    local dy=$(( $2 > $4 ? $2 - $4 : $4 - $2 ))
    echo $((dx + dy))
}

is_walkable() {
    (( $1 < 0 || $1 >= MAP_WIDTH || $2 < 0 || $2 >= MAP_HEIGHT )) && return 1
    local c="${MAP[$(( $2 * MAP_WIDTH + $1 ))]}"
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

h0=$(heuristic $START_X $START_Y $GOAL_X $GOAL_Y)
G_SCORE["$START_X,$START_Y"]=0
open_add $h0 $START_X $START_Y

PATH_FOUND=0
for ((ITER=0; ITER<10000; ITER++)); do
    IFS=',' read -r f x y <<< "$(open_get_lowest)"
    [[ "$x" == "-1" ]] && break
    key="$x,$y"
    [[ -n ${CLOSED[$key]+x} ]] && continue
    CLOSED[$key]=1

    if (( x == GOAL_X && y == GOAL_Y )); then
        PATH_FOUND=1
        break
    fi

    for dir in "0,-1" "0,1" "-1,0" "1,0"; do
        IFS=',' read -r dx dy <<< "$dir"
        nx=$((x + dx)); ny=$((y + dy))
        is_walkable $nx $ny || continue
        nkey="$nx,$ny"
        [[ -n ${CLOSED[$nkey]+x} ]] && continue

        tentative_g=$(( ${G_SCORE[$key]} + 1 ))
        if [[ -z ${G_SCORE[$nkey]+x} ]] || (( tentative_g < ${G_SCORE[$nkey]} )); then
            CAME_FROM_X[$nkey]=$x
            CAME_FROM_Y[$nkey]=$y
            G_SCORE[$nkey]=$tentative_g
            h=$(heuristic $nx $ny $GOAL_X $GOAL_Y)
            open_add $((tentative_g + h)) $nx $ny
        fi
    done
done

if (( PATH_FOUND == 0 )); then
    echo "No path found!"
    exit 1
fi

x=$GOAL_X; y=$GOAL_Y
while ! (( x == START_X && y == START_Y )); do
    key="$x,$y"
    px=${CAME_FROM_X[$key]}; py=${CAME_FROM_Y[$key]}
    [[ -z "$px" ]] && break
    idx=$(( y * MAP_WIDTH + x ))
    [[ "${MAP[idx]}" != "@" && "${MAP[idx]}" != "#" ]] && MAP[idx]='*'
    x=$px; y=$py
done

for (( y=0; y<MAP_HEIGHT; y++ )); do
    for (( x=0; x<MAP_WIDTH; x++ )); do
        printf '%s' "${MAP[$((y * MAP_WIDTH + x))]}"
    done
    printf '\n'
done
