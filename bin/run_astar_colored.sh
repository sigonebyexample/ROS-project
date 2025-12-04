#!/bin/bash

MAPFILE="$1"
[[ ! -f "$MAPFILE" ]] && { echo "File not found!"; exit 1; }


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/read_map.sh"
source "$SCRIPT_DIR/lib/find_points.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
read_map "$MAPFILE"
find_points


GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
WHITE='\033[0m'
BLACK='\033[0;30m'

declare -A G_SCORE CAME_FROM_X CAME_FROM_Y CLOSED
OPEN_FILE=$(mktemp)
trap "rm -f $OPEN_FILE; tput cnorm" EXIT

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

clear
tput civis  

while true; do
    IFS=',' read -r f x y <<< "$(open_get_lowest)"
    [[ "$x" == "-1" ]] && break

    key="$x,$y"
    [[ -n ${CLOSED[$key]+x} ]] && continue
    CLOSED[$key]=1

    clear
    for (( yy=0; yy<MAP_HEIGHT; yy++ )); do
        for (( xx=0; xx<MAP_WIDTH; xx++ )); do
            idx=$((yy * MAP_WIDTH + xx))
            char="${MAP[idx]}"
           
            if [[ -n ${CLOSED["$xx,$yy"]+x} ]]; then
                if [[ "$char" != "@" && "$char" != "#" ]]; then
                    char="o"
                fi
            fi
        
            if (( xx == x && yy == y )) && [[ "$char" != "@" && "$char" != "#" ]]; then
                char="+"
            fi

            case "$char" in
                '@') echo -ne "${GREEN}@${WHITE}" ;;
                '#') echo -ne "${RED}#${WHITE}" ;;
                'o'|'+') echo -ne "${GRAY}$char${WHITE}" ;;
                '1') echo -ne "${BLACK}1${WHITE}" ;;
                '0') echo -ne "0" ;;
                '*') echo -ne "${BLUE}*${WHITE}" ;;
                *) echo -ne "$char" ;;
            esac
        done
        echo
    done
    printf "\n🔍 Processing node: (%d, %d)\n" $x $y
    sleep 0.3

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

tput cnorm  

if (( PATH_FOUND == 0 )); then
    echo -e "\n${RED}❌ No path found!${WHITE}"
    exit 1
fi


x=$GOAL_X; y=$GOAL_Y
while ! (( x == START_X && y == START_Y )); do
    key="$x,$y"
    px=${CAME_FROM_X[$key]}; py=${CAME_FROM_Y[$key]}
    [[ -z "$px" ]] && break
    idx=$(( y * MAP_WIDTH + x ))
    if [[ "${MAP[idx]}" != "@" && "${MAP[idx]}" != "#" ]]; then
        MAP[idx]='*'
    fi
    x=$px; y=$py
done

clear
echo -e "${GREEN}✅ Final Path:${WHITE}"
for (( y=0; y<MAP_HEIGHT; y++ )); do
    for (( x=0; x<MAP_WIDTH; x++ )); do
        idx=$((y * MAP_WIDTH + x))
        char="${MAP[idx]}"
        case "$char" in
            '@') echo -ne "${GREEN}@${WHITE}" ;;
            '#') echo -ne "${RED}#${WHITE}" ;;
            '*') echo -ne "${BLUE}*${WHITE}" ;;
            '1') echo -ne "${BLACK}1${WHITE}" ;;
            *) echo -ne "$char" ;;
        esac
    done
    echo
done