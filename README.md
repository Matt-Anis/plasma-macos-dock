<p align="center">
  <img src="assets/logo.png" alt="macOS Dock Logo" width="256" />
</p>

# macOS Dock-Like Experience for KDE Plasma 6

A native widget for KDE Plasma 6 that brings a smooth, responsive macOS dock-like experience to your Linux desktop. Built directly on top of KDE's official Icons-Only Task Manager, it transforms the taskbar into a floating, magnified capsule while keeping all native Plasma system integrations, Wayland window management, and application workflows fully intact.

## Table of Contents

- [Installation](#installation)
- [Introduction](#introduction)
- [Features](#features)
  - [Custom Icon Sizing and Spacing](#custom-icon-sizing-and-spacing)
  - [Capsule Padding and Edge Elevation](#capsule-padding-and-edge-elevation)
  - [Interactive Magnification Wave](#interactive-magnification-wave)
  - [Spring and Smooth Animation Physics](#spring-and-smooth-animation-physics)
  - [Hover Lift Elevation](#hover-lift-elevation)
  - [Capsule Styling and Custom Colors](#capsule-styling-and-custom-colors)
  - [External Running Indicator Dots](#external-running-indicator-dots)
  - [Pinned and Running Tasks Divider](#pinned-and-running-tasks-divider)
  - [All-Edge Screen Placement Support](#all-edge-screen-placement-support)
- [How It Works and Architectural Decisions](#how-it-works-and-architectural-decisions)
  - [Why Build on Icons-Only Task Manager](#why-build-on-icons-only-task-manager)
  - [Cosine-Squared Parabolic Wave Math](#cosine-squared-parabolic-wave-math)
  - [Dynamic Layering and Elevated Hitbox Protection](#dynamic-layering-and-elevated-hitbox-protection)
  - [Padding-Anchored Status Dots](#padding-anchored-status-dots)
  - [Edge-Aware Coordinate Transformations](#edge-aware-coordinate-transformations)
  - [Unified Configuration Architecture](#unified-configuration-architecture)
- [Recommended Setup](#recommended-setup)
- [Known Limitations](#known-limitations)
- [License](#license)

---

## Installation

### Manual Installation from Source

1. Clone this repository into your local Plasma plasmoids directory:

   ```bash
   git clone https://github.com/Matt-Anis/plasma-macos-dock.git ~/.local/share/plasma/plasmoids/com.github.mattanis.macosdock
   ```

2. Restart Plasma Shell to register the applet:

   ```bash
   systemctl --user restart plasma-plasmashell
   ```

3. Right-click your desktop or an existing panel, select **Add Widgets...**, and add **macOS Dock** to your screen.

---

## Introduction

This widget provides a macOS dock-like experience inside KDE Plasma 6. It is built directly on KDE's native Icons-Only Task Manager codebase (`org.kde.plasma.icontasks`), replacing the standard flat panel look with an elevated floating dock capsule, fluid icon magnification, and refined visual styling without sacrificing stability or Wayland compatibility.

---

## Features

### Custom Icon Sizing and Spacing

Unlike standard taskbars where icon size is constrained by panel height, this dock lets you define custom icon dimensions and spacing independently.

- **How to use**: Open dock settings under **Appearance > Icons & Dimensions**. Use the **Icon size (px)** spinbox to set your base icon size (from 24px up to 256px), and adjust **Icon spacing (px)** to control the gap between neighboring icons.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing adjustable icon sizing and spacing -->

```markdown
![Icon Sizing and Spacing](placeholders/icon-sizing-spacing.gif)
```

### Capsule Padding and Edge Elevation

The dock sits inside a floating capsule with customizable inner padding and an elevation offset that lifts the entire dock away from the monitor edge.

- **How to use**: In dock settings under **Appearance > Icons & Dimensions**, configure **Horizontal padding (px)** and **Vertical padding (px)** to control inner capsule margins around icons. Adjust **Elevation offset (px)** to raise the dock above the screen edge.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing capsule padding and elevation offset -->

```markdown
![Capsule Padding and Elevation](placeholders/padding-elevation.gif)
```

### Interactive Magnification Wave

Hovering over dock icons triggers a smooth, continuous magnification wave where the target icon expands and neighboring icons scale progressively according to proximity.

- **How to use**: In dock settings under **Appearance > Magnification & Animation**, turn on **Magnify icons on hover**. Use the **Zoom scale** spinbox to choose the peak magnification factor (from 1.0x up to 2.0x), and set the **Blast radius (icons)** to specify how many neighboring icons scale alongside the hovered icon (1 to 4 items on each side).
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing magnification wave with custom scale and blast radius -->

```markdown
![Magnification Wave](placeholders/magnification-wave.gif)
```

### Spring and Smooth Animation Physics

You can choose between physical spring simulation or cubic easing curves for icon magnification.

- **How to use**: In dock settings under **Appearance > Magnification & Animation**, select your preference in the **Animation physics** dropdown:
  - **Spring physics**: Employs elastic simulation with subtle damping for a bouncy, tactile feel.
  - **Smooth**: Uses a clean cubic ease-out curve for steady, linear transitions.
- **Visual preview**:

<!-- PLACEHOLDER: GIF comparing Spring physics vs Smooth animation -->

```markdown
![Animation Physics](placeholders/animation-physics.gif)
```

### Hover Lift Elevation

When icons magnify on hover, they can simultaneously lift upward away from the panel base toward the cursor.

- **How to use**: Under **Appearance > Magnification & Animation**, adjust the **Hover lift (px)** spinbox (from 0px up to 32px). Higher values make icons elevate toward the mouse cursor as they scale up.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing hover lift elevation effect -->

```markdown
![Hover Lift Elevation](placeholders/hover-lift.gif)
```

### Capsule Styling and Custom Colors

The dock background capsule can be styled as a solid frosted pill, a transparent container, or a custom tinted surface with border outlines.

- **How to use**: In dock settings under **Appearance > Capsule & Style**:
  - Set **Container background** to either **Solid** or **Transparent**.
  - Click **Choose Color...** next to **Background color** to select any custom background tint or opacity.
  - Configure **Border thickness (px)** and use **Choose Color...** next to **Border color** to customize the capsule stroke outline.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing custom background colors and border styling -->

```markdown
![Capsule Styling](placeholders/capsule-styling.gif)
```

### External Running Indicator Dots

Running applications display a subtle indicator dot placed in the capsule padding beneath the icon rather than drawn over the icon graphic itself.

- **How to use**: In dock settings under **Appearance > Previews & Indicators**, check **Show indicator for running applications**. The indicator glows bright white for the active window and dims to soft translucent white for background or minimized windows.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing running indicator dots in active and background states -->

```markdown
![Running Indicators](placeholders/running-indicators.gif)
```

### Pinned and Running Tasks Divider

The dock automatically generates a subtle vertical or horizontal separator line between your pinned application launchers and unpinned running windows.

- **How to use**: Pin favorite applications to your dock. When you open an unpinned app, a clean translucent divider appears automatically between the launcher section and the open window section.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing dynamic separator between pinned and running windows -->

```markdown
![Tasks Divider](placeholders/tasks-divider.gif)
```

### All-Edge Screen Placement Support

The dock works on any screen edge, automatically adjusting its orientation, lift direction, indicator offset, and popup placement.

- **How to use**: Place your Plasma panel on the Bottom, Top, Left, or Right edge of your display. The dock detects the screen edge automatically, rotating the capsule layout, directing icon hover lift inward toward the desktop, and adjusting indicator dot positions.
- **Visual preview**:

<!-- PLACEHOLDER: GIF showing dock operating on Bottom, Top, Left, and Right screen edges -->

```markdown
![All Edge Placement](placeholders/all-edge-placement.gif)
```

---

## How It Works and Architectural Decisions

### Why Build on Icons-Only Task Manager

Developing a dock as an independent application often leads to window management desynchronization, Wayland protocol incompatibilities, missing system tray coordination, and duplicate resource consumption.

Building directly upon KDE Plasma's `org.kde.plasma.icontasks` keeps all native window tracking, LibTaskManager models, virtual desktop filters, activity assignments, window thumbnails, and MPRIS audio stream controls native to the shell. This delivers an authentic dock experience without third-party daemons or compositor workarounds.

### Cosine-Squared Parabolic Wave Math

Magnification calculation in `main.qml` uses a normalized cosine-squared curve rather than a simple linear step function:

```text
distance = abs(iconIndex - hoveredIndex)
u = distance / (blastRadius + 1)
factor = (0.5 * (1 + cos(pi * u)))^2
```

This mathematical formula produces a smooth bell curve whose first derivative approaches zero at the boundary edges. Neighboring icons ease into expansion gradually and return to rest without abrupt jumps or snapping artifacts.

### Dynamic Layering and Elevated Hitbox Protection

When icons scale up and lift toward the mouse cursor, standard layouts frequently suffer from overlapping z-order glitches or lose pointer hover as the icon geometry shifts. Two architectural choices resolve this:

1. **Dynamic Stacking Order**: Each task item computes its `z` property dynamically from its instantaneous zoom level (`Math.round(effectiveZoom * 100)`). The hovered icon always renders in front of its immediate neighbors, which in turn render in front of resting icons.
2. **Elevated Hitbox Extension**: A dedicated `hoverHitBox` item projects outward into the panel padding by `maxElevatedReach`. Even when an icon lifts 20px or 30px off the dock floor, the mouse cursor remains inside the interactive area, preventing hover flickering.

### Padding-Anchored Status Dots

In standard KDE taskbars, running indicators overlay the bottom edge of application graphics, often clashing with icon artwork.

In this dock, running indicator dots are anchored outside the icon box into the dock capsule padding margin (`padOffset`). By calculating the remaining margin between the icon edge and the capsule border, indicators float in the dedicated padding cushion, leaving application icons completely unobstructed.

### Edge-Aware Coordinate Transformations

KDE Plasma panels can be positioned on any monitor edge. Rather than assuming a bottom-panel setup, the dock evaluates an internal `effectiveLocation` property:

- Checks whether the dock is horizontal (`BottomEdge` or `TopEdge`) or vertical (`LeftEdge` or `RightEdge`).
- Automatically directs hover lift transformations inward toward the workspace.
- Anchors indicator dots into the appropriate outer padding margin (bottom, top, left, or right).
- Aligns context menus and window preview popups so they always open away from the screen edge.

### Unified Configuration Architecture

The configuration backend extends KDE's `kcfg` schema with explicit definitions for every dock parameter (`iconSize`, `elevation`, `zoomMultiplier`, `containerBackgroundColor`, and related properties). The UI is organized into dedicated sections within Kirigami form layouts, giving users immediate access to dimensions, physics, colors, and behavior without burying options in unrelated submenus.

---

## Recommended Setup

For the most authentic dock presentation:

1. **Plasma Panel Settings**:
   - Panel mode: Set to **Fit Content** or centered floating.
   - Opacity: Set panel background to **Transparent** so the dock capsule renders its own background.
2. **Dock Settings**:
   - **Icons & Dimensions**: Icon size `48px`, Icon spacing `4px`, Elevation `8px`.
   - **Magnification & Animation**: Zoom scale `1.5x`, Blast radius `2`, Animation `Spring physics`, Hover lift `12px`.
   - **Capsule & Style**: Border thickness `1px`, Container background `Solid`.

---

## Known Limitations

- **No Background Blur**: This widget intentionally does not implement background blur out of the box. Custom background blur within Plasma widgets typically depends on external C++ helper plugins, compositor shaders, or third-party tools that complicate installation. Omitting background blur by design keeps this dock lightweight, self-contained, and easy to install on any standard KDE Plasma 6 system without extra dependencies. Another version featuring full background blur and glassmorphism is planned and will be built soon.

---

## License

This project is licensed under the GNU General Public License v2.0 or later (GPL-2.0-or-later). See the project files for full copyright and licensing details.
