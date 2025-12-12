#!/bin/bash

MAPFILE="$1"
[[ ! -f "$MAPFILE" ]] && { echo "File not found!"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/read_map.sh"
source "$SCRIPT_DIR/lib/find_points.sh"
source "$SCRIPT_DIR/lib/astar_core.sh"
source "$SCRIPT_DIR/lib/reconstruct.sh"

read_map "$MAPFILE"
find_points
run_astar
reconstruct_path