#!/bin/bash

# Logger module - structured logging with levels/colors

# Log levels - DEBUG(0) < INFO(1) < WARN(2) < ERROR(3)
readonly LOG_DEBUG=0    # Verbose debugging info
readonly LOG_INFO=1     # Standard operational messages  
readonly LOG_WARN=2     # Non-critical issues
readonly LOG_ERROR=3    # Critical errors/failures

# Current verbosity level
CURRENT_LOG_LEVEL=$LOG_INFO  # Default: show INFO+

# Terminal color setup
if [[ -t 1 ]]; then  # Check if stdout is terminal
    readonly COLOR_RED='\033[1;31m'      # Bright red
    readonly COLOR_GREEN='\033[1;32m'    # Bright green  
    readonly COLOR_YELLOW='\033[1;33m'   # Bright yellow
    readonly COLOR_BLUE='\033[1;34m'     # Bright blue
    readonly COLOR_MAGENTA='\033[1;35m'  # Bright magenta
    readonly COLOR_CYAN='\033[1;36m'     # Bright cyan
    readonly COLOR_RESET='\033[0m'       # Reset formatting
else
    # No colors if output redirected
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_MAGENTA=''
    readonly COLOR_CYAN=''
    readonly COLOR_RESET=''
fi

# Set current log verbosity
set_log_level() {
    local level="$1"  # DEBUG|INFO|WARN|ERROR
    case "$level" in
        "DEBUG") CURRENT_LOG_LEVEL=$LOG_DEBUG ;;  # Most verbose
        "INFO")  CURRENT_LOG_LEVEL=$LOG_INFO  ;;  # Default level  
        "WARN")  CURRENT_LOG_LEVEL=$LOG_WARN  ;;  # Warnings+
        "ERROR") CURRENT_LOG_LEVEL=$LOG_ERROR ;;  # Errors only
        *) log_error "Bad log level: $level" ;;   # Invalid input
    esac
}

# Debug messages - dev/verbose only
log_debug() {
    if [[ $CURRENT_LOG_LEVEL -le $LOG_DEBUG ]]; then  # DEBUG level check
        echo -e "${COLOR_BLUE}[DEBUG]${COLOR_RESET} $1" >&2  # Stderr + blue
    fi
}

# Info messages - standard output  
log_info() {
    if [[ $CURRENT_LOG_LEVEL -le $LOG_INFO ]]; then  # INFO level check
        echo -e "${COLOR_CYAN}ℹ[INFO]${COLOR_RESET} $1"  # Stdout + cyan
    fi
}

# Warning messages - non-critical issues
log_warning() {
    if [[ $CURRENT_LOG_LEVEL -le $LOG_WARN ]]; then  # WARN level check
        echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1" >&2  # Stderr + yellow
    fi
}

# Error messages - critical failures  
log_error() {
    if [[ $CURRENT_LOG_LEVEL -le $LOG_ERROR ]]; then  # ERROR level check
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1" >&2  # Stderr + red
    fi
}

# Success messages - always shown
log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"  # Always stdout + green
}

# Section headers - visual separation
log_section() {
    echo ""  # Blank line before section
    echo -e "${COLOR_MAGENTA}══════ $1 ══════${COLOR_RESET}"  # Magenta separator
}

# Module self-test
test_logger() {
    echo "Logger module test"
    echo "____________________________"
    
    set_log_level "DEBUG"  # Set to most verbose
    log_debug "Debug message example"   # Should appear
    log_info "Info message example"     # Should appear  
    log_warning "Warning message example"  # Should appear
    log_error "Error message example"   # Should appear
    log_success "Success message example"  # Should appear
    log_section "Section header example"   # Should appear
    
    echo ""
    echo "✅ Logger test passed"
}

# Run test if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script run as ./logger.sh
    test_logger  # Execute self-test
fi