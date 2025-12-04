# A* Pathfinding in Pure Bash

A complete implementation of the **A\* pathfinding algorithm** in **pure Bash**, with:
- 🎲 Random map generator
- 🖥️ GUI frontend (Zenity)
- 🎨 Colored step-by-step terminal visualization
- No external dependencies (only Bash + coreutils)

## 📁 Structure
- `bin/`      → Executable scripts
- `lib/`      → Core A* modules
- `maps/`     → Sample and generated maps
- `astar_gui.sh` → Main GUI launcher

## ▶️ Quick Start

1. Make sure you have `zenity` installed:
   ```bash
   sudo apt install zenity
2. Run the GUI:
    ```bash
    ./astar_gui.sh
3. choose:
-    `Generate New Random Map`
-    `Run A (Simple in GUI)*`
-    `Run A Colored (Terminal)*`
## 💻 Requirements
-   `Bash 4.0+`
-   `GNU coreutils (sort, mktemp, etc.)`
-   `zenity (for GUI)`
-   `gnome-terminal or xterm (for colored mode)`