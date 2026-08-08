# AFRICA RUSH (Prototype)

AFRICA RUSH is a 3D mobile arcade racing game prototype created with Godot 4.x.
This repository contains the initial project structure and Phase 1 foundation: a Godot project file, a basic main scene, core script, and documentation to continue development.

## Status (PHASE 1)
- Initial Godot project structure created
- Main scene (minimal) added
- Core script placeholder added
- Documentation and Android build instructions added

## Requirements
- Godot 4.0+ (stable recommended)
- Android SDK and command-line tools (for Android export)
- Java JDK 11+ (for Android export)

## How to open
1. Install Godot 4.x from https://godotengine.org
2. Clone this repository:
   git clone https://github.com/nicholasmulwamulwa-eng/SMARTRACER.git
3. Open the project folder in Godot (open the folder containing `project.godot`).
4. Open `scenes/main/Main.tscn` and run the scene or set the project to run the main scene.

## How to run (editor)
- Open Godot, click 'Import' or 'Open' and select this repository folder.
- Press Play (F5) to run the main scene.

## Project layout (high level)
- assets/         - art, models, audio, textures
- scenes/         - Godot scenes (main, menus, cars, tracks, race)
- scripts/        - GDScript code organized by subsystem
- data/           - serialized data, car and track definitions
- docs/           - documentation (android build, play store, architecture)

## Next (PHASE 2)
- Implement player car controller and driving input
- Create a simple physics-based vehicle prototype
- Add touch controls and mobile input mappings

## Notes
- No secrets or keystores are included. See docs/build_android.md for Android signing guidance.
