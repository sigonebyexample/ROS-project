#!/bin/bash

    Shebang declaration that tells the system to execute this script using the Bash shell
    Ensures consistent behavior across different Unix-like systems

MAPFILE="$1"

    Stores the first command-line argument (the map filename) in the MAPFILE variable
    Example: ./script.sh mymap.txt sets MAPFILE="mymap.txt"

[[ ! -f "$MAPFILE" ]] && { echo "File not found!"; exit 1; }

    Input validation that checks if the specified map file exists
    [[ ! -f "$MAPFILE" ]] returns true if the file does NOT exist
    If the file is missing, it prints an error message and exits with code 1 (indicating failure)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    Determines the project root directory regardless of where the script is executed from
    "${BASH_SOURCE[0]}" = full path of the current script file
    dirname = extracts the directory path (removes the filename)
    "/.." = navigates up one level to the project root
    pwd = resolves to the absolute path
    Result: SCRIPT_DIR contains the full path to your project root

source "$SCRIPT_DIR/lib/read_map.sh"

    Loads the read_map function from the library file
    source executes the file in the current shell environment, making its functions available
    This function reads and parses the map file into memory

source "$SCRIPT_DIR/lib/find_points.sh"

    Loads the find_points function from the library file
    This function scans the loaded map to locate the start (@) and goal (#) positions

source "$SCRIPT_DIR/lib/astar_core.sh"

    Loads the run_astar function from the library file
    This function contains the core A* pathfinding algorithm implementation

source "$SCRIPT_DIR/lib/reconstruct.sh"

    Loads the reconstruct_path function from the library file
    This function backtracks from goal to start to build the final path and displays it

read_map "$MAPFILE"

    Executes the map reading function with the user-provided map file
    Parses the text file into a data structure that the algorithm can work with

find_points

    Executes the point finding function on the loaded map
    Identifies and stores the coordinates of start (@) and goal (#) positions

run_astar

    Executes the A pathfinding algorithm*
    Computes the shortest path from start to goal using the A* algorithm
    Stores the path information in internal data structures

reconstruct_path

    Generates and displays the final result
    Backtracks through the computed path and marks it with * characters
    Prints the complete map with the path visualized to stdout