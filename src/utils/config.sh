#!bin/bash
# Utility functions for configuration management
# We will load the map from here
readonly START_CHAR='@'
readonly END_CHAR='#'
readonly PATH_CHAR='.'
readonly WALL_CHAR='1'
readonly EMPTY_CHAR='0'
readonly DEFAULT_MAP_FILE="map.txt"
# We will start to modify A* algorithm from here
HEURISTIC_TYPE="manhattan" # Options: manhattan, euclidean, diagonal
MOVEMENT_MODE=10          # Cost for orthogonal movement
DIAGONAL_COST=14  # Cost for diagonal movement
STAIGHT_COST=10  # Cost for straight movement
# We will start Display settings from here
COLOR_ENABLED=true
ANIMATION_SPEED=100  # in milliseconds
SHOW_STATS=true
# We will start logging settings from here
LOG_LEVEL="info"  # Options: debug, info, warning, error
LOG_TO_FILE=false
LOG_FILE="a_star.log"
# From this part CONFIGURATION settings will be added
load_config() {
    local config_file="${1:-config/default_config.cfg}" # This line is for loading default config file
    if [[ -f "$config_file" ]]; then #This line checks if the config file exists
        log_warning "Loading configuration from $config_file" # This line logs a warning message about loading the config file
        source "$config_file" # This line sources the config file to load settings
    else
        log_warning "Configuration file $config_file not found. Using default settings." # This line logs a warning message if the config file is not found
    fi
}
# Function to validate configuration settings
validate_config() {
    case "$HEURISTIC_TYPE" in # THis line starts a case statement to validate the HEURISTIC_TYPE variable
    "manhattan" | "euclidean" | "diagonal") # Valid options
        ;;
    *)
        log_error "Invalid HEURISTIC_TYPE: $HEURISTIC_TYPE. Defaulting to 'manhattan'." # Log error for invalid heuristic type
        HEURISTIC_TYPE="manhattan" # Default to manhattan
        ;;
    esac
    # Neigbor_mode validation
    case "$NEIGHBOR_MODE" in
    "four" | "eight") # In this line checks for valid NEIGHBOR_MODE options
        ;;
    *)
        log_warning "NEIGHBOR_MODE set to invalid value: $NEIGHBOR_MODE. Defaulting to 'four'." # Log warning for invalid neighbor mode