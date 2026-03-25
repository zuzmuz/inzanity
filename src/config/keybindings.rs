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
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Action {
    // Navigation
    MoveUp,
    MoveDown,
    MoveLeft,
    MoveRight,

    // Mode transitions
    EnterCommand,
    EnterInsert,
    EnterVisual,
    ExitMode, // back to Normal

    // Transport
    TogglePlay,

    // App
    Quit,
    Confirm, // Enter
}

pub struct KeyMap(HashMap<(Mode, KeyBinding), Action>);

impl KeyMap {
    pub fn default_bindings() -> Self {
        let mut map = HashMap::new();

        let mut bind = |mode, code, action: Action| {
            map.insert((mode, KeyBinding::new(code)), action);
        };

        // Normal mode
        bind(Mode::Normal, KeyCode::Char('j'), Action::MoveDown);
        bind(Mode::Normal, KeyCode::Char('k'), Action::MoveUp);
        bind(Mode::Normal, KeyCode::Char('h'), Action::MoveLeft);
        bind(Mode::Normal, KeyCode::Char('l'), Action::MoveRight);
        bind(Mode::Normal, KeyCode::Char(':'), Action::EnterCommand);
        bind(Mode::Normal, KeyCode::Char('i'), Action::EnterInsert);
        bind(Mode::Normal, KeyCode::Char('v'), Action::EnterVisual);
        bind(Mode::Normal, KeyCode::Char(' '), Action::TogglePlay);
        bind(Mode::Normal, KeyCode::Char('q'), Action::Quit);

        // Insert mode
        bind(Mode::Insert, KeyCode::Esc, Action::ExitMode);
        bind(Mode::Insert, KeyCode::Char('j'), Action::MoveDown);
        bind(Mode::Insert, KeyCode::Char('k'), Action::MoveUp);
        bind(Mode::Insert, KeyCode::Char('h'), Action::MoveLeft);
        bind(Mode::Insert, KeyCode::Char('l'), Action::MoveRight);

        // Visual mode
        bind(Mode::Visual, KeyCode::Esc, Action::ExitMode);
        bind(Mode::Visual, KeyCode::Char('j'), Action::MoveDown);
        bind(Mode::Visual, KeyCode::Char('k'), Action::MoveUp);
        bind(Mode::Visual, KeyCode::Char('h'), Action::MoveLeft);
        bind(Mode::Visual, KeyCode::Char('l'), Action::MoveRight);

        // Command mode
        bind(Mode::Command, KeyCode::Esc, Action::ExitMode);
        bind(Mode::Command, KeyCode::Enter, Action::Confirm);

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
