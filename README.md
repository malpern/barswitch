# BarSwitch

A lightweight macOS daemon that coordinates between [SketchyBar](https://github.com/FelixKratz/SketchyBar) and the native macOS menu bar.

## The Problem

If you use SketchyBar with the native macOS menu bar set to "auto-hide," both bars fight for the same space at the top of the screen. When you move your mouse up to reveal the native menu bar, it slides down *over* SketchyBar, creating an ugly overlap. There's no built-in way to coordinate them.

## What BarSwitch Does

BarSwitch watches your mouse position and:

1. **Mouse approaches the top of the screen** — BarSwitch hides SketchyBar so the native menu bar can appear cleanly
2. **Mouse moves away from the top** — BarSwitch slides SketchyBar back into view

The result: you get SketchyBar as your primary status bar, with seamless access to the native menu bar whenever you need it. The two never overlap.

## Install

### Build from source

```bash
git clone https://github.com/malpern/barswitch.git
cd barswitch
swift build -c release
cp .build/release/barswitch /usr/local/bin/
```

Requires Swift 5.9+ and macOS 13 (Ventura) or later.

### Permissions

BarSwitch needs **Input Monitoring** permission to track mouse position:

1. Run `barswitch --check-permissions` to verify
2. If denied: **System Settings > Privacy & Security > Input Monitoring** — add the `barswitch` binary

## Usage

```bash
# Run with defaults
barswitch

# Custom thresholds
barswitch --trigger-zone 10 --menu-bar-height 50 --debounce 150

# Check permissions
barswitch --check-permissions

# Print version
barswitch --version
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--trigger-zone <px>` | 10 | Distance from top of screen (in pixels) that triggers SketchyBar to hide |
| `--menu-bar-height <px>` | 50 | Distance from top that defines the menu bar zone — SketchyBar won't reappear until the mouse is below this |
| `--debounce <ms>` | 150 | Delay in milliseconds before SketchyBar reappears, prevents flicker on rapid mouse movement |
| `--check-permissions` | | Check if Input Monitoring permission is granted |
| `--version` | | Print version |
| `--help` | | Show help |

## Auto-start with launchd

Copy the included plist to start BarSwitch automatically at login:

```bash
cp com.barswitch.agent.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.barswitch.agent.plist
```

To stop:

```bash
launchctl unload ~/Library/LaunchAgents/com.barswitch.agent.plist
```

Logs are written to `/tmp/barswitch.log`.

## How It Works

BarSwitch uses a passive [CGEventTap](https://developer.apple.com/documentation/coregraphics/cgevent) to monitor mouse movement at the Core Graphics level. This is event-driven (zero CPU when the mouse isn't moving) and works globally across all apps, including fullscreen.

The core logic is a simple state machine:

```
SKETCHYBAR_VISIBLE (default)
  → mouse enters trigger zone (top 10px)
  → hide SketchyBar instantly

SKETCHYBAR_HIDDEN
  → mouse leaves menu bar zone (below 50px)
  → wait for debounce (150ms)
  → slide SketchyBar back into view
```

BarSwitch controls SketchyBar via its CLI (`sketchybar --bar hidden=on/off`) and uses SketchyBar's built-in animation system for smooth transitions.

## Architecture

```
barswitch/
├── Package.swift
├── Sources/
│   ├── BarSwitchCore/              # Library — all testable logic
│   │   ├── BarController.swift     # Protocol for bar control (enables mocking)
│   │   ├── StateMachine.swift      # State machine: visible ↔ hidden with debounce
│   │   ├── EventTap.swift          # CGEventTap setup + screen geometry
│   │   ├── SketchyBarController.swift  # Shells out to sketchybar CLI
│   │   └── Config.swift            # CLI argument parsing
│   └── BarSwitch/
│       └── main.swift              # Entry point, signal handlers, run loop
├── Tests/
│   └── BarSwitchTests/             # 27 unit tests
├── com.barswitch.agent.plist       # launchd plist for auto-start
└── README.md
```

## Requirements

- macOS 13+ (Ventura)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- Swift 5.9+ (build only)
- No runtime dependencies — uses only system frameworks (CoreGraphics, AppKit, Foundation)

## License

MIT
