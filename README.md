# UMBRAL: El Último Intervalo 🌌⚔️
### *High-Performance Non-Euclidean Soulsvania & Physics Framework for Godot 4*

[![Godot Engine](https://img.shields.io/badge/Godot_Engine-4.7.2_Forward%2B-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)](https://godotengine.org)
[![Physics](https://img.shields.io/badge/Physics-Jolt_3D_120Hz-orange?style=for-the-badge)](https://github.com/godot-jolt/godot-jolt)
[![Target Performance](https://img.shields.io/badge/Target-1080p_@_120FPS-2ea44f?style=for-the-badge)](#technical-architecture)
[![License: MIT](https://img.shields.io/badge/Code_License-MIT-blue?style=for-the-badge)](LICENSE)
[![Test Suite](https://img.shields.io/badge/Unit_Tests-100%25_Passing-brightgreen?style=for-the-badge)](#automated-testing)

---

## 📖 Overview

**UMBRAL: El Último Intervalo** is an open-architecture, high-performance 2.5D Action-Soulsvania game and experimental framework developed in **Godot Engine 4.7.2 Forward+**. 

The project bridges the gap in the open-source Godot ecosystem for deterministic, high-frequency martial combat mechanics, non-Euclidean spatial shaders, and adaptive boss AI architectures. Designed from the ground up for strict frame budgeting (8.33 ms frame budget target at 120 FPS), UMBRAL features an integrated suite of reusable modules, shaders, and unit tests designed to accelerate open-source game development.

---

## ⚡ Core Technical Innovations & Modules

### 1. Non-Euclidean PBR Spatial Loom Shaders
* **Mathematical Foundation:** Implements $C^2$ continuous spatial manifold deformations with analytical normal vector recalculation via inverted transposed Jacobian matrices:
  $$\mathbf{N}' = \text{normalize}\left((J^{-1})^T \mathbf{N}\right)$$
* **Volumetric Scattering:** Custom Mie scattering fog with Henyey-Greenstein phase function ($g = 0.76$) for forward light dispersion in gothic cathedrals and ruins.
* **Astral Resonance:** Dynamic silhouette fresnel terms modulated by phase shift states $R \in [0, 1]$.

### 2. High-Frequency Jolt Physics Kinematics (120 Hz)
* `physics_ticks_per_second = 120` execution synchronized directly with `PhysicsServer3D`.
* Dynamic gravity scaling $\eta(R, \alpha)$ enabling zero-gravity suspension in spatial folds and polar ceiling inversion during Phase Shift.
* Sub-millisecond impact stops (*hitstop*) and buffer-driven parry windows verified down to individual frames.

### 3. Neuro-Symbiotic Adaptive Boss AI
* Quantized micro-telegraphed state machines (36-frame / 300 ms telegraph windows).
* Dynamic parry-spam mitigation and 14-frame / 18-frame retention feints.
* Multi-phase boss architecture with persistent phase transition logic and spatial zone locking.

### 4. Atomic Save & Continuity Anchor System
* 100% blind atomic JSON serialization preventing save corruption during asynchronous zone transitions.
* Verified across regression test harnesses (`test_ancla.gd`: 22/22 OK, 0 failures).

---

## 🧪 Automated Testing Suite

The framework prioritizes architectural rigor through a comprehensive headless testing harness:

| Test Suite | Coverage Area | Status |
| :--- | :--- | :---: |
| `tests/test_movimiento.gd` | Kinematics, acceleration, jump arcs & ledge buffering | **9 / 9 Passing** |
| `tests/test_combate.gd` | Frame data, hitboxes, hurtboxes, poise & stagger | **17 / 17 Passing** |
| `tests/test_desfase.gd` | Dimensional phase shifting & resonance pools | **28 / 28 Passing** |
| `tests/test_costura.gd` | Tethering mechanics, stitch & severance logic | **17 / 17 Passing** |
| `tests/test_enemigos.gd` | Enemy state machines, agro radii & archetypes | **29 / 29 Passing** |
| `tests/test_ancla.gd` | State persistence, atomic serialization & respawn | **22 / 22 Passing** |
| `tests/test_prefecto.gd` | Boss phases, portal traversal & closing mechanics | **24 / 24 Passing** |

To run the complete test suite headlessly:
```bash
godot --headless --path . -- --run-tests
```

---

## 🎮 Hardware Target & Render Pipeline

* **Primary Renderer:** Godot Forward+ (Vulkan 1.3)
* **Optimization Target:** 1080p @ 120 FPS (8.33 ms frame budget on NVIDIA GeForce RTX 4050 / modern desktop GPUs).
* **Compatibility Fallback:** Automatic dynamic fallback to Godot Compatibility (OpenGL 3) for integrated graphics (validated at 52+ FPS on basic Intel UHD 610).
* **Audio Engine:** Procedural & synthesized diegetic sound design integrated via custom master bus routing.

---

## 🛠️ Project Structure

```
UMBRAL/
├── assets/
│   ├── shaders/           # Non-Euclidean, Henyey-Greenstein & Fresnel shaders
│   ├── modelos_3d/        # Optimized GLTF/GLB models & collision meshes
│   └── texturas/          # PBR texture sets (CC0 / Permissive)
├── scenes/
│   ├── jugador/           # Nereth player controller, inputs, and state machines
│   ├── enemigos/          # Boss and archetype enemy scene trees
│   ├── ui/                # Stylized HUD, Sekiro-style posture bars & menus
│   └── niveles/           # Elyndor level scenes & spatial rooms
├── scripts/
│   ├── core/              # Physics controllers, combat math & atomic save
│   └── pipeline_3d/       # Asset pipeline, rigging & export automation
├── tests/                 # Full automated unit testing suite
├── documentation/         # Master production documentation & math papers
└── project.godot          # Engine configuration & autoload definitions
```

---

## 📜 Licensing

* **Source Code & Shaders:** Licensed under the [MIT License](LICENSE). Reusable for community projects, indie titles, and academic research.
* **Game Lore, Narrative & Characters:** © 2026 Juan José Orejuela Riascos. All rights reserved.
* **Third-Party Assets:** Documented with respective CC0 / OFL licenses in `assets/LICENCIAS.md`.

---

## 🤝 Open Source & Ecosystem Vision

UMBRAL is committed to advancing the open-source Godot ecosystem. As vertical slices and systems mature, individual components (the Loom Shader Library, High-Frequency Jolt Controller, and Headless Test Harness) are packaged as standalone open-source Godot addons for the wider indie community.
