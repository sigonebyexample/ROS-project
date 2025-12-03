#!/bin/bash
# Config manager for pathfinding - vars and validation

# Map symbols
readonly START_CHAR='@'      # Start position marker
readonly END_CHAR='#'        # Goal position marker  
readonly PATH_CHAR='.'       # Path visualization char
readonly WALL_CHAR='1'       # Obstacle/wall char
readonly EMPTY_CHAR='0'      # Traversable empty cell
readonly DEFAULT_MAP_FILE="map.txt"  # Default map file

# Algorithm tuning
HEURISTIC_TYPE="manhattan"   # manhattan|euclidean|diagonal
MOVEMENT_MODE=10             # Orthogonal move cost
DIAGONAL_COST=14             # ~sqrt(2)*10 for diagonal moves
STAIGHT_COST=10              # Straight move cost

# Display/UI settings
COLOR_ENABLED=true           # ANSI colors on/off
ANIMATION_SPEED=100          # ms delay for animations
SHOW_STATS=true              # Show runtime stats

# Logging config
LOG_LEVEL="info"             # debug|info|warning|error
LOG_TO_FILE=false            # Log to file toggle
LOG_FILE="a_star.log"        # Log file name

# Load external config file
load_config() {
    local config_file="${1:-config/default_config.cfg}"  # Param or default
    if [[ -f "$config_file" ]]; then                     # File exists check
        log_warning "Loading config from $config_file"   # Log load event
        source "$config_file"                            # Execute config
    else
        log_warning "Config file $config_file not found. Using defaults."
    fi
}

# Validate config values
validate_config() {
    # Heuristic type check
    case "$HEURISTIC_TYPE" in
    "manhattan" | "euclidean" | "diagonal")  # Valid options
        ;;
    *)
        log_error "Invalid HEURISTIC_TYPE: $HEURISTIC_TYPE. Using 'manhattan'."
        HEURISTIC_TYPE="manhattan"           # Fallback default
        ;;
    esac

    # Neighbor mode validation
    case "$NEIGHBOR_MODE" in
    "four" | "eight")  # 4-dir vs 8-dir movement
        ;;
    *)
        log_warning "Invalid NEIGHBOR_MODE: $NEIGHBOR_MODE. Defaulting to 'four'."
        NEIGHBOR_MODE="four"                 # 4-directional default
        ;;
    esac

    # Cost validation - must be positive
    if [[ $DIAGONAL_COST -le 0 ]]; then      # Check diagonal cost
        log_warning "DIAGONAL_COST must be >0. Setting to 14."
        DIAGONAL_COST=14                     # Default: sqrt(2)*10
    fi

    if [[ $STAIGHT_COST -le 0 ]]; then       # Check straight cost
        log_warning "STAIGHT_COST must be >0. Setting to 10."
        STAIGHT_COST=10                      # Base movement cost
    fi

    return 0  # Validation successful
}

# Print current config state
show_config() {
    echo "Current Configuration Settings:"
    echo "Map Symbols:"
    echo "  Start: $START_CHAR"
    echo "  End: $END_CHAR"
    echo "  Path: $PATH_CHAR"
    echo "  Wall: $WALL_CHAR"
    echo "  Empty: $EMPTY_CHAR"
    echo "Algorithm Parameters:"
    echo "  Heuristic Type: $HEURISTIC_TYPE"
    echo "  Neighbor Mode: $NEIGHBOR_MODE"
    echo "  Diagonal Cost: $DIAGONAL_COST"
    echo "  Straight Cost: $STAIGHT_COST"
    echo "Display Settings:"
    echo "  Color enabled: $COLOR_ENABLED"
    echo "  Animation speed: $ANIMATION_SPEED ms"
    echo "  Stats enabled: $SHOW_STATS"
    echo "Logging Settings:"
    echo "  Log Level: $LOG_LEVEL"
    echo "  Log to File: $LOG_TO_FILE ($LOG_FILE)"
}

# Prevent direct execution when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # File is being sourced/imported
    echo "A* Config Utility Loaded."
    echo "========================="
    show_config  # Display config on load
fi