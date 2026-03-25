use anyhow::Result;
use crossterm::event::{Event, KeyEvent};
use ratatui::Frame;

use crate::config::keybindings::{Action, KeyMap};
use crate::domain::{project::Project, ticks::TICKS_PER_BEAT};
use crate::state::mode::Mode;
use crate::ui::theme::Theme;

pub struct AppState {
    pub mode: Mode,
    pub playing: bool,
    pub project: Option<Box<Project>>,
    pub cursor_track: usize,
    pub scroll_tick: u64,
    pub ticks_per_col: u64,
    pub command_input: String,
    pub status_message: Option<String>,
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            mode: Mode::default(),
            playing: false,
            project: None,
            cursor_track: 0,
            scroll_tick: 0,
            ticks_per_col: TICKS_PER_BEAT / 4, // sixteenth note per column
            command_input: String::new(),
            status_message: None,
        }
    }
}

pub struct App {
    pub state: AppState,
    pub should_quit: bool,
    keymap: KeyMap,
    theme: Theme,
}

impl App {
    pub fn new() -> Self {
        Self {
            state: AppState::default(),
            should_quit: false,
            keymap: KeyMap::default_bindings(),
            theme: Theme::default(),
        }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        match &event {
            Event::Key(KeyEvent { code, modifiers, .. }) => {
                // Command mode: capture raw chars for the input buffer
                if self.state.mode == Mode::Command {
                    use crossterm::event::KeyCode;
                    match code {
                        KeyCode::Char(c) => {
                            self.state.command_input.push(*c);
                            return Ok(());
                        }
                        KeyCode::Backspace => {
                            self.state.command_input.pop();
                            return Ok(());
                        }
                        _ => {}
                    }
                }

                if let Some(action) = self.keymap.get(self.state.mode, *code, *modifiers) {
                    self.handle_action(action);
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn handle_action(&mut self, action: Action) {
        let state = &mut self.state;
        let track_count = state.project.as_ref().map(|p| p.tracks.len()).unwrap_or(0);

        match action {
            Action::Quit => self.should_quit = true,

            Action::EnterCommand => {
                state.mode = Mode::Command;
                state.command_input.clear();
            }
            Action::EnterInsert => state.mode = Mode::Insert,
            Action::EnterVisual => state.mode = Mode::Visual,
            Action::ExitMode => {
                state.mode = Mode::Normal;
                state.command_input.clear();
            }

            Action::Confirm => {
                if state.mode == Mode::Command {
                    let cmd = state.command_input.trim().to_string();
                    state.command_input.clear();
                    state.mode = Mode::Normal;
                    self.execute_command(&cmd);
                }
            }

            Action::MoveUp => {
                state.cursor_track = state.cursor_track.saturating_sub(1);
            }
            Action::MoveDown => {
                if track_count > 0 {
                    state.cursor_track = (state.cursor_track + 1).min(track_count - 1);
                }
            }
            Action::MoveLeft => {
                state.scroll_tick = state.scroll_tick.saturating_sub(state.ticks_per_col * 4);
            }
            Action::MoveRight => {
                state.scroll_tick += state.ticks_per_col * 4;
            }

            Action::TogglePlay => {
                state.playing = !state.playing;
            }
        }
    }

    fn execute_command(&mut self, cmd: &str) {
        match cmd {
            "q" | "quit" => self.should_quit = true,
            "w" => {
                self.state.status_message = Some("save not yet implemented".into());
            }
            _ => {
                self.state.status_message = Some(format!("unknown command: {cmd}"));
            }
        }
    }

    pub fn render(&self, frame: &mut Frame) {
        crate::ui::render(frame, &self.state, &self.theme);
    }
}
