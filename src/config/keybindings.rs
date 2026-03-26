use std::collections::HashMap;

use crossterm::event::{KeyCode, KeyModifiers};

use crate::state::mode::Mode;

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
    // Cursor movement
    MoveUp,
    MoveDown,
    MoveLeft,
    MoveRight,

    // Scrolling (independent of cursor)
    ScrollUp,
    ScrollDown,
    ScrollLeft,
    ScrollRight,

    // Zoom
    ZoomInH,
    ZoomOutH,
    ZoomInV,
    ZoomOutV,

    // Mode transitions
    EnterCommand,
    EnterInsert,
    EnterVisual,
    ExitMode,

    // Transport
    TogglePlay,

    // App
    Quit,
    Confirm,
}

pub struct KeyMap(HashMap<(Mode, KeyBinding), Action>);

impl KeyMap {
    pub fn default_bindings() -> Self {
        let mut map: HashMap<(Mode, KeyBinding), Action> = HashMap::new();

        // Normal mode — cursor
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('j'))), Action::MoveDown);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('k'))), Action::MoveUp);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('h'))), Action::MoveLeft);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('l'))), Action::MoveRight);

        // Normal mode — scroll viewport (Ctrl+d/u/f/b, vim-style)
        map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('d'))), Action::ScrollDown);
        map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('u'))), Action::ScrollUp);
        map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('f'))), Action::ScrollRight);
        map.insert((Mode::Normal, KeyBinding::ctrl(KeyCode::Char('b'))), Action::ScrollLeft);

        // Normal mode — horizontal zoom (= zoom in, - zoom out)
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('='))), Action::ZoomInH);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('-'))), Action::ZoomOutH);

        // Normal mode — vertical zoom (+ / _)
        // Shift+= sends '+', Shift+- sends '_' — bind the resulting chars directly
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('+'))), Action::ZoomInV);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('_'))), Action::ZoomOutV);

        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char(':'))), Action::EnterCommand);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('i'))), Action::EnterInsert);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('v'))), Action::EnterVisual);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char(' '))), Action::TogglePlay);
        map.insert((Mode::Normal, KeyBinding::new(KeyCode::Char('q'))), Action::Quit);

        // Insert mode
        map.insert((Mode::Insert, KeyBinding::new(KeyCode::Esc)), Action::ExitMode);
        map.insert((Mode::Insert, KeyBinding::new(KeyCode::Char('j'))), Action::MoveDown);
        map.insert((Mode::Insert, KeyBinding::new(KeyCode::Char('k'))), Action::MoveUp);
        map.insert((Mode::Insert, KeyBinding::new(KeyCode::Char('h'))), Action::MoveLeft);
        map.insert((Mode::Insert, KeyBinding::new(KeyCode::Char('l'))), Action::MoveRight);

        // Visual mode
        map.insert((Mode::Visual, KeyBinding::new(KeyCode::Esc)), Action::ExitMode);
        map.insert((Mode::Visual, KeyBinding::new(KeyCode::Char('j'))), Action::MoveDown);
        map.insert((Mode::Visual, KeyBinding::new(KeyCode::Char('k'))), Action::MoveUp);
        map.insert((Mode::Visual, KeyBinding::new(KeyCode::Char('h'))), Action::MoveLeft);
        map.insert((Mode::Visual, KeyBinding::new(KeyCode::Char('l'))), Action::MoveRight);

        // Command mode
        map.insert((Mode::Command, KeyBinding::new(KeyCode::Esc)), Action::ExitMode);
        map.insert((Mode::Command, KeyBinding::new(KeyCode::Enter)), Action::Confirm);

        // Ctrl-C quits from any mode
        for mode in [Mode::Normal, Mode::Insert, Mode::Visual, Mode::Command] {
            map.insert((mode, KeyBinding::ctrl(KeyCode::Char('c'))), Action::Quit);
        }

        Self(map)
    }

    pub fn get(&self, mode: Mode, code: KeyCode, modifiers: KeyModifiers) -> Option<Action> {
        self.0.get(&(mode, KeyBinding { code, modifiers })).copied()
    }
}
