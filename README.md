# 🕹️ Cloud Climber

## 📌 Overview
**Cloud Climber** is a side-scrolling 2D platformer game developed entirely in **MIPS Assembly Language**.
This project showcases low-level graphics rendering, real-time input handling, and game logic implemented at the assembly level, 
using the bitmap display capabilities provided in MIPS simulators.

## 🎯 Objective
Navigate a cloud-like character through **three progressively difficult levels**, jumping between platforms, avoiding deadly floors, and collecting 
interactive power-ups. The ultimate goal is to reach the top platform on **Level 3**, where victory awaits. However, losing all health points will trigger a game over screen.

## 🧠 Key Features

### ✅ Milestone 3 Achievements
- **3 Distinct Levels** with decreasing platform density and increasing challenge.
- **Health System** with visual heart indicators (3 lives per level).
- **Fail Condition:** Fall damage or hazard contact removes health; 0 lives = game over.
- **Win Condition:** Reaching the final platform on Level 3 completes the game.
- **Moving Platforms** add dynamic difficulty to the final level.

### ✨ Additional Features
- **Power-Up Pickups:**
  - 🟡 **Yellow Star:** Changes the character's color for the level.
  - 💗 **Pink Star:** Fully restores all 3 hearts.
  - 💜 **Purple Star:** Removes one heart (avoid at all costs).
- **Reset Mechanism:** Press the **'P' key** at any time to restart from Level 1.
- **Collision Detection** with platforms, floors, and items implemented manually.
- **Dynamic Gravity System**: Characters fall unless supported by a platform.

## 🎮 Controls

| Key | Action         |
|-----|----------------|
| `A` | Move Left      |
| `D` | Move Right     |
| `W` | Jump / Move Up |
| `P` | Restart Game   |

> ⚠️ The game requires a MIPS simulator that supports memory-mapped I/O and bitmap display
>  (e.g., [MARS](http://courses.missouristate.edu/kenvollmar/mars/) or QtSPIM with the Bitmap Display tool).

## 🖥️ Display Configuration

- **Bitmap Unit Size:** 8x8 pixels  
- **Resolution:** 512x512 pixels  
- **Base Address:** `0x10008000 ($gp)`

## 📁 Project Structure

- `main:` Game entry point and Level 1 logic
- `level2:` Initializes and runs Level 2
- `level3:` Initializes and runs Level 3
- `draw_*:` Rendering routines for character, hearts, platforms, and items
- `erase_*:` Graphics removal routines
- `gravity:` Handles character falling and collision detection
- `moving_platform:` Controls moving platforms in Level 3
- `game_over` and `win:` Display final screen visuals

## 🛡️ Health and Lives

- Players start each level with **3 red hearts**.
- Falling on the **gray floor** or touching a **purple star** deducts one heart.
- A **pink star** restores all three hearts.
- All lives reset at the beginning of each new level.

## 🚀 Getting Started

To run the game:

1. Open the `.asm` file in a supported MIPS simulator.
2. Enable the Bitmap Display tool.
3. Configure the display as follows:
   - **Unit width:** `8`
   - **Unit height:** `8`
   - **Display width:** `512`
   - **Display height:** `512`
   - **Base address:** `0x10008000`
4. Run the program and use the keyboard controls to play.

## 🏁 End Screens

- **Win Screen** appears when the player reaches the final platform on Level 3.
- **Game Over Screen** appears if the player loses all hearts.
