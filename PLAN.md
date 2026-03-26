# Inzanity — TUI DAW Implementation Plan

## Overview

A text-based Digital Audio Workstation built in Rust using ratatui. Keyboard-centric with vim-like modal motions. Compose MIDI tracks, record and play audio, fully customizable.

---

## Architecture

Four strictly decoupled layers:

```
TUI (ratatui)  →  App State  →  Domain/Engine  →  I/O (MIDI, Audio, File)
```

The main loop polls terminal events and engine channel messages (~60fps), updates state, then re-renders. Background threads (MIDI sequencer, audio engine) communicate exclusively via `crossbeam-channel` — they never share mutable state with the main thread.

---

## Dependencies

| Crate | Purpose |
|---|---|
| `ratatui` + `crossterm` | TUI rendering and terminal backend |
| `midir` | MIDI port I/O (CoreMIDI on macOS) |
| `midly` | MIDI event parsing and encoding |
| `cpal` | Cross-platform audio I/O |
| `symphonia` | Audio file decoding (mp3, wav, ogg) |
| `serde` + `serde_yaml` | Project file serialization |
| `base64` | Encode/decode MIDI data in project files |
| `crossbeam-channel` | RT-safe inter-thread messaging |
| `anyhow` | Error propagation |
| `uuid` | Track/item ID generation |
| `toml` + `dirs` | User config file at `~/.config/inzanity/config.toml` |
| `dasp` / `rubato` | (later) Sample rate conversion and DSP |

---

## Module Structure

```
src/
├── main.rs                  # Entry point: terminal init, run app loop, clean shutdown
├── app.rs                   # App struct, top-level event dispatch, run loop
│
├── ui/
│   ├── mod.rs               # Root render function, layout computation
│   ├── arrangement.rs       # Arrangement view: timeline, tracks, items
│   ├── piano_roll.rs        # Piano roll editor (Insert mode)
│   ├── mixer.rs             # Mixer/channel strip view
│   ├── transport.rs         # Transport bar (BPM, position, play/stop/record)
│   ├── command_bar.rs       # Bottom command line (Command mode)
│   └── theme.rs             # Color palettes, style definitions
│
├── state/
│   ├── mod.rs               # AppState struct
│   ├── mode.rs              # Mode enum, ModeController, transition table
│   ├── cursor.rs            # Cursor position (track index, beat, pitch)
│   ├── selection.rs         # Visual mode selection ranges
│   └── focus.rs             # Which panel currently has focus
│
├── domain/
│   ├── mod.rs
│   ├── project.rs           # Project: metadata, tempo track, track list
│   ├── track.rs             # Track: id, name, mute/solo/armed, items
│   ├── item.rs              # Item: position, duration, ItemSource enum
│   ├── tempo_track.rs       # TempoChange, TimeSignatureChange, beat↔tick math
│   └── ticks.rs             # Tick/Tempo/Bpm newtypes and conversions
│
├── engine/
│   ├── mod.rs
│   ├── sequencer.rs         # MIDI sequencer: playback state, event scheduling
│   ├── transport.rs         # Transport state: playing/paused/recording, position
│   ├── audio_engine.rs      # Audio graph, mixing, cpal stream management
│   └── clock.rs             # Internal clock: tick advancement, tempo sync
│
├── midi/
│   ├── mod.rs
│   ├── port_manager.rs      # Enumerate and connect midir ports
│   ├── event.rs             # Internal MIDI event type
│   └── encode.rs            # base64 ↔ raw bytes ↔ midly events
│
├── audio/
│   ├── mod.rs
│   ├── decoder.rs           # symphonia-based file decoding
│   ├── buffer.rs            # Lock-free ring buffer for RT audio streaming
│   └── resampler.rs         # Sample rate conversion
│
├── config/
│   ├── mod.rs
│   ├── keybindings.rs       # KeyMap: per-mode key→action bindings
│   ├── theme_config.rs      # User-overridable color/style config
│   └── settings.rs          # Audio settings: sample rate, buffer size, device
│
├── commands/
│   ├── mod.rs               # Command enum and dispatcher
│   └── parser.rs            # Parse `:command args` strings into Command variants
│
├── persistence/
│   ├── mod.rs
│   ├── project_io.rs        # Load/save project YAML
│   └── undo.rs              # Undo/redo stack (command pattern)
│
└── errors.rs                # Domain error types
```

---

## Vim Modal Modes

Four modes implemented as a strict state machine in `ModeController`. Transitions are defined in a static table — no mode logic scattered in rendering code.

| Mode | Purpose |
|---|---|
| `Normal` | Navigate arrangement, playback controls, track selection |
| `Insert` | Piano roll note entry and editing |
| `Visual` | Range selection across the timeline |
| `Command` | Bottom-bar command line |

The controller also holds a pending operator buffer for motion sequences (e.g. `3j`, future `dw`-style operators) and the previous mode for `<C-o>` temporary Normal mode.

### Default Keybindings (Normal mode)

| Key | Action |
|---|---|
| `h/j/k/l` | Navigate (scroll left/down/up/right) |
| `<Space>` | Play/Stop toggle |
| `<Enter>` | Open item in piano roll (Insert mode) |
| `v` | Enter Visual mode |
| `:` | Enter Command mode |
| `m` | Toggle mixer panel |
| `?` | Help overlay |
| `u` / `<C-r>` | Undo / Redo |
| `a` | Add track |
| `d` | Delete selected |
| `+` / `-` | Zoom in / out |

### Command mode examples

```
:w              save project
:q              quit
:bpm 140        set tempo
:track add      add a new track
:bind n <space> play   rebind key at runtime
:midi out <port>       select MIDI output port
```

---

## Critical Design Notes

### Tick Resolution
The project format uses `2^20` (1,048,576) ticks per beat. All position calculations in the sequencer, audio engine, and renderer must use this resolution. The `ticks.rs` module defines:
- `Tick(u64)` — absolute timeline position
- `TickDuration(u64)` — a duration in ticks
- `Bpm(f64)` — beats per minute
- `Tempo(f64)` — beats per second (project file stores `2.0` = 120 BPM)
- Conversion utilities: `ticks_to_seconds`, `beat_to_tick`, etc.

### Audio RT Safety
The `cpal` stream callback runs on a real-time thread. It must **never allocate or block**. Design:
- A dedicated mixing thread prepares audio and writes to a lock-free ring buffer.
- The cpal callback only reads from that ring buffer.
- The mixing thread is fed project data via channels from the main thread.

### Playhead Sharing
Transport position is exposed as `Arc<AtomicU64>` (current tick). The UI thread reads it directly without locking the sequencer.

### Scroll and Zoom
`ticks_per_column: u64` drives zoom. Default: `ticks_per_beat / 4` (sixteenth note per column). Zoom in halves it; zoom out doubles it. Item render column: `(item.position - scroll_start_tick) / ticks_per_column`.

### Error Handling
- I/O errors (missing file, MIDI port disconnect): surface as red status message in command bar, no crash.
- Audio underruns: log to debug overlay, do not interrupt playback.
- Unrecoverable errors: restore terminal via `Drop` on the terminal handle before panicking.

---

## Phased Roadmap

### Phase 1 — TUI Skeleton
**Goal:** Working ratatui app with modal state machine and basic layout. No audio or MIDI.

- [x] Add `ratatui`, `crossterm`, `anyhow`, `serde`, `serde_yaml`, `uuid` to `Cargo.toml`
- [x] Implement `domain/` structs (`Project`, `Track`, `Item`, `Tick`, `Tempo`) with serde
- [x] Implement `state/mode.rs` — four modes, transition table, `ModeController`
- [x] Implement `config/keybindings.rs` with hardcoded defaults
- [x] Build `app.rs` run loop: terminal init, event poll, draw, clean shutdown
- [x] Implement `ui/arrangement.rs` — static read-only view of loaded project
- [x] Implement `ui/transport.rs` — static bar showing BPM and time position
- [x] Implement `ui/command_bar.rs` — mode indicator, `:` command entry, `:q` to quit
- [x] Wire `hjkl` navigation in Normal mode

**Deliverable:** Load a project file, display the arrangement, navigate with `hjkl`, quit with `:q`.

---

### Phase 2 — Project Editing and Persistence
**Goal:** Full CRUD on the project from the TUI; reliable save/load.

- [x] Implement `commands/` with `Command` enum and parser
- [ ] Implement `persistence/undo.rs` — command-pattern undo/redo stack
- [ ] Track operations: add, delete, rename, reorder, mute/solo/arm
- [ ] Item operations: move, resize, copy/paste, delete (Visual mode selection)
- [ ] Load user config from `~/.config/inzanity/config.toml`
- [ ] Runtime keybinding via `:bind` command
- [ ] `:w` / `:w <path>` save; `:e <path>` open
- [ ] Zoom in/out on the arrangement timeline

**Deliverable:** Full project editing without audio/MIDI. Round-trip through the project file format.

---

### Phase 3 — MIDI Sequencer
**Goal:** Play back MIDI items through connected MIDI ports; display live playhead.

- [ ] Add `midir`, `midly`, `base64`, `crossbeam-channel` to `Cargo.toml`
- [ ] Implement `midi/encode.rs` — base64 ↔ raw bytes ↔ midly events
- [ ] Implement `midi/port_manager.rs` — enumerate and connect ports
- [ ] Implement `engine/clock.rs` — tick-advancing thread at correct tempo
- [ ] Implement `engine/sequencer.rs` — walk items in tick order, fire MIDI events
- [ ] Implement `engine/transport.rs` — Play/Stop/Pause/Record; `Arc<AtomicU64>` playhead
- [ ] Wire `<Space>` to Play/Stop
- [ ] Render live playhead in arrangement view
- [ ] Implement `ui/piano_roll.rs` — full-screen MIDI editor (Insert mode)
- [ ] Note entry in piano roll: `hjkl` navigate, `a` add note, `x` delete
- [ ] MIDI input recording with armed tracks

**Deliverable:** Full MIDI playback and basic composition in the piano roll.

---

### Phase 4 — Audio Engine
**Goal:** Play back audio items through system audio output.

- [ ] Add `cpal`, `symphonia` to `Cargo.toml`
- [ ] Implement `audio/decoder.rs` — decode mp3/wav/ogg to `Vec<f32>`
- [ ] Implement `audio/buffer.rs` — lock-free ring buffer
- [ ] Implement `engine/audio_engine.rs` — mixing graph, feeds ring buffer
- [ ] Implement `cpal` output stream reading from ring buffer
- [ ] Integrate audio start/stop with transport
- [ ] Per-track volume and pan at mix time
- [ ] Mute/solo across MIDI and audio tracks
- [ ] Waveform rendering in arrangement view (block characters)

**Deliverable:** MIDI + audio playback in sync.

---

### Phase 5 — Polish and Advanced Features
**Goal:** Production-quality UX and extensibility.

- [ ] Full theme system: user palettes, built-in light/dark presets
- [ ] Help overlay (`?`) showing current mode keybindings
- [ ] MIDI port selection menu
- [ ] Tempo automation: multiple tempo/time-sig changes in arrangement
- [ ] Mixer panel (`m`) with keyboard-navigable channel strips
- [ ] Clip looping with loop markers
- [ ] Lua scripting hooks via `mlua` for custom keybindings and processing
- [ ] Project templates and clip library
- [ ] Performance pass: stable 30fps+ with large projects
- [ ] Robust error recovery (corrupted file, missing audio, port disconnect)
