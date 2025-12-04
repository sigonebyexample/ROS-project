#!/bin/bash

WIDTH=10
HEIGHT=10
WALL_RATIO=30
OUTPUT="random_map.txt"

while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--width) WIDTH="$2"; shift 2 ;;
        -h|--height) HEIGHT="$2"; shift 2 ;;
        -r|--ratio) WALL_RATIO="$2"; shift 2 ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if (( WIDTH < 3 || HEIGHT < 3 )); then
    echo "Error: Width and height must be at least 3!" >&2
    exit 1
fi
if (( WALL_RATIO < 0 || WALL_RATIO > 100 )); then
    echo "Error: Wall ratio must be between 0 and 100!" >&2
    exit 1
fi

declare -A GRID
for (( y=0; y<HEIGHT; y++ )); do
    for (( x=0; x<WIDTH; x++ )); do
        GRID[$y,$x]="0"
    done
done

for (( x=0; x<WIDTH; x++ )); do
    GRID[0,$x]="1"
    GRID[$((HEIGHT-1)),$x]="1"
done
for (( y=0; y<HEIGHT; y++ )); do
    GRID[$y,0]="1"
    GRID[$y,$((WIDTH-1))]="1"
done

START_X=$(( RANDOM % (WIDTH - 2) + 1 ))
START_Y=$(( RANDOM % (HEIGHT - 2) + 1 ))
GOAL_X=$(( RANDOM % (WIDTH - 2) + 1 ))
GOAL_Y=$(( RANDOM % (HEIGHT - 2) + 1 ))

while (( START_X == GOAL_X && START_Y == GOAL_Y )); do
    GOAL_X=$(( RANDOM % (WIDTH - 2) + 1 ))
    GOAL_Y=$(( RANDOM % (HEIGHT - 2) + 1 ))
done

x=$START_X
y=$START_Y
while (( x != GOAL_X )); do
    if (( x < GOAL_X )); then ((x++)); else ((x--)); fi
    GRID[$y,$x]="0"
done
while (( y != GOAL_Y )); do
    if (( y < GOAL_Y )); then ((y++)); else ((y--)); fi
    GRID[$y,$x]="0"
done

GRID[$START_Y,$START_X]="@"
GRID[$GOAL_Y,$GOAL_X]="#"

for (( y=1; y<HEIGHT-1; y++ )); do
    for (( x=1; x<WIDTH-1; x++ )); do
        if [[ "${GRID[$y,$x]}" == "0" ]]; then
            if (( RANDOM % 100 < WALL_RATIO )); then
                is_adjacent=0
                for dy in -1 0 1; do
                    for dx in -1 0 1; do
                        if (( dx == 0 && dy == 0 )); then continue; fi
                        if (( x == START_X + dx && y == START_Y + dy )) || (( x == GOAL_X + dx && y == GOAL_Y + dy )); then
                            is_adjacent=1
                        fi
                    done
                done
                if (( is_adjacent == 0 )); then
                    GRID[$y,$x]="1"
                fi
            fi
        fi
    done
done

{
    for (( y=0; y<HEIGHT; y++ )); do
        for (( x=0; x<WIDTH; x++ )); do
            printf '%s' "${GRID[$y,$x]}"
        done
        printf '\n'
    done
} > "$OUTPUT"

echo "✅ Random map generated: $OUTPUT" >&2
echo "   Size: ${WIDTH}x${HEIGHT}" >&2
echo "   Wall ratio: ${WALL_RATIO}%" >&2