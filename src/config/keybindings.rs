use std::collections::HashMap;

use crossterm::event::{KeyCode, KeyModifiers};

use crate::state::mode::Mode;
use crate::state::panel::Panel;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct KeyBinding {
    pub code: KeyCode,
    pub modifiers: KeyModifiers,
}

impl KeyBinding {
    pub fn new(code: KeyCode) -> Self {
        Self { code, modifiers: KeyModifiers::NONE }
    }

    pub fn ctrl(code: KeyCode) -> Self {
        Self { code, modifiers: KeyModifiers::CONTROL }
    }

    pub fn shift(code: KeyCode) -> Self {
        Self { code, modifiers: KeyModifiers::SHIFT }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Action {
    // Cursor / navigation
    MoveUp,
    MoveDown,

    // Timeline scroll (Arrange panel)
    ScrollTimelineLeft,
    ScrollTimelineRight,

    // Viewport scroll (global, Ctrl+d/u/f/b)
    ScrollUp,
    ScrollDown,
    ScrollLeft,
    ScrollRight,

    // Zoom
    ZoomInH,
    ZoomOutH,
    ZoomInV,
    ZoomOutV,

    // Panel switching
    SwitchPanel,

    // Mode transitions
    EnterCommand,
    EnterInsert,
    ExitMode,

    // Transport
    TogglePlay,

    // Track list actions
    AddTrack,
    DeleteTrack,
    RenameTrack,
    MuteTrack,
    SoloTrack,
    ArmTrack,

    // Arrange actions
    EditItem,

    // App
    Quit,
    Confirm,
}

pub struct KeyMap {
    /// Panel-specific bindings active in Normal mode only.
    panel_map: HashMap<(Panel, KeyBinding), Action>,
    /// Bindings active regardless of panel, keyed by (Mode, KeyBinding).
    global_map: HashMap<(Mode, KeyBinding), Action>,
}

impl KeyMap {
    pub fn default_bindings() -> Self {
        let mut panel_map: HashMap<(Panel, KeyBinding), Action> = HashMap::new();
        let mut global_map: HashMap<(Mode, KeyBinding), Action> = HashMap::new();

        // ── TrackList panel (Normal mode) ──────────────────────────────
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('j'))), Action::MoveDown);
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('k'))), Action::MoveUp);
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('a'))), Action::AddTrack);
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('d'))), Action::DeleteTrack);
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('r'))), Action::RenameTrack);
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('m'))), Action::MuteTrack);
        panel_map.insert((Panel::TrackList, KeyBinding::new(KeyCode::Char('s'))), Action::SoloTrack);
        panel_map.insert((Panel::TrackList, KeyBinding::shift(KeyCode::Char('a'))), Action::ArmTrack);

        // ── Arrange panel (Normal mode) ────────────────────────────────
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('j'))), Action::MoveDown);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('k'))), Action::MoveUp);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('h'))), Action::ScrollTimelineLeft);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('l'))), Action::ScrollTimelineRight);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('='))), Action::ZoomInH);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('-'))), Action::ZoomOutH);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('+'))), Action::ZoomInV);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Char('_'))), Action::ZoomOutV);
        panel_map.insert((Panel::Arrange, KeyBinding::new(KeyCode::Enter)), Action::EditItem);

        // ── Global — Normal mode ───────────────────────────────────────
        global_map.insert((Mode::Normal, KeyBinding::new(KeyCode::Tab)), Action::SwitchPanel);
        global_map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char(' '))), Action::TogglePlay);
        global_map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char(':'))), Action::EnterCommand);
        global_map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('q'))), Action::Quit);
        global_map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('d'))), Action::ScrollDown);
        global_map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('u'))), Action::ScrollUp);
        global_map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('f'))), Action::ScrollRight);
        global_map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('b'))), Action::ScrollLeft);

        // ── Global — Insert mode ───────────────────────────────────────
        global_map.insert((Mode::Insert, KeyBinding::new(KeyCode::Esc)), Action::ExitMode);

        // ── Global — Command mode ──────────────────────────────────────
        global_map.insert((Mode::Command, KeyBinding::new(KeyCode::Esc)), Action::ExitMode);
        global_map.insert((Mode::Command, KeyBinding::new(KeyCode::Enter)), Action::Confirm);

        // ── Ctrl-C quits from any mode ─────────────────────────────────
        for mode in [Mode::Normal, Mode::Insert, Mode::Command] {
            global_map.insert((mode, KeyBinding::ctrl(KeyCode::Char('c'))), Action::Quit);
        }

        Self { panel_map, global_map }
    }

    pub fn get(&self, panel: Panel, mode: Mode, code: KeyCode, modifiers: KeyModifiers) -> Option<Action> {
        let binding = KeyBinding { code, modifiers };
        // Panel-specific bindings only active in Normal mode
        if mode == Mode::Normal {
            if let Some(action) = self.panel_map.get(&(panel, binding)) {
                return Some(*action);
            }
        }
        self.global_map.get(&(mode, binding)).copied()
    }
}
