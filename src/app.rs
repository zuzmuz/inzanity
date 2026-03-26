use anyhow::Result;
use crossterm::event::{Event, KeyEvent};
use ratatui::Frame;

use crate::config::keybindings::{Action, KeyMap};
use crate::domain::{project::Project, ticks::TICKS_PER_BEAT, track::Track};
use crate::persistence::project_io;
use crate::state::mode::Mode;
use crate::ui::theme::Theme;

const MIN_TICKS_PER_COL: u64 = TICKS_PER_BEAT / 256; // 64th note
const MAX_TICKS_PER_COL: u64 = TICKS_PER_BEAT * 16; // 16 beats
const MIN_TRACK_HEIGHT: u16 = 1;
const MAX_TRACK_HEIGHT: u16 = 16;

pub struct AppState {
    pub mode: Mode,
    pub playing: bool,
    pub project: Option<Box<Project>>,
    pub cursor_track: usize,
    pub scroll_tick: u64,
    pub scroll_track: usize,
    pub ticks_per_col: u64,
    pub track_height: u16,
    pub command_input: String,
    pub status_message: Option<String>,
    /// Updated each frame by the renderer; used to keep cursor in view.
    pub viewport_track_rows: u16,
}

impl AppState {
    pub fn visible_tracks(&self) -> usize {
        (self.viewport_track_rows / self.track_height.max(1)) as usize
    }
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            mode: Mode::default(),
            playing: false,
            project: None,
            cursor_track: 0,
            scroll_tick: 0,
            scroll_track: 0,
            ticks_per_col: TICKS_PER_BEAT / 4,
            track_height: 1,
            command_input: String::new(),
            status_message: None,
            viewport_track_rows: 20, // sensible default until first frame
        }
    }
}

pub struct App {
    pub state: AppState,
    pub should_quit: bool,
    /// Path of the currently open project file, if any.
    pub project_path: Option<std::path::PathBuf>,
    keymap: KeyMap,
    theme: Theme,
}

impl App {
    pub fn new() -> Self {
        Self {
            state: AppState::default(),
            should_quit: false,
            project_path: None,
            keymap: KeyMap::default_bindings(),
            theme: Theme::default(),
        }
    }

    pub fn load_project(&mut self, path: &std::path::Path) {
        match project_io::load(path) {
            Ok(project) => {
                self.project_path = Some(path.to_path_buf());
                self.state.project = Some(Box::new(project));
                self.state.cursor_track = 0;
                self.state.scroll_track = 0;
                self.state.scroll_tick = 0;
                self.state.status_message = Some(format!("loaded {}", path.display()));
            }
            Err(e) => {
                self.state.status_message = Some(format!("error: {e}"));
            }
        }
    }

    pub fn save_project(&mut self, path: &std::path::Path) {
        match &self.state.project {
            None => self.state.status_message = Some("no project open".into()),
            Some(project) => match project_io::save(project, path) {
                Ok(()) => {
                    self.project_path = Some(path.to_path_buf());
                    self.state.status_message = Some(format!("saved {}", path.display()));
                }
                Err(e) => {
                    self.state.status_message = Some(format!("error: {e}"));
                }
            },
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

            // Cursor moves selection
            Action::MoveUp => {
                state.cursor_track = state.cursor_track.saturating_sub(1);
                // Keep cursor in view
                if state.cursor_track < state.scroll_track {
                    state.scroll_track = state.cursor_track;
                }
            }
            Action::MoveDown => {
                if track_count > 0 {
                    state.cursor_track = (state.cursor_track + 1).min(track_count - 1);
                    // Scroll viewport to follow cursor downward
                    if state.cursor_track >= state.scroll_track + state.visible_tracks() {
                        state.scroll_track = state.cursor_track + 1 - state.visible_tracks();
                    }
                }
            }
            Action::MoveLeft => {
                state.scroll_tick = state.scroll_tick.saturating_sub(state.ticks_per_col * 4);
            }
            Action::MoveRight => {
                state.scroll_tick += state.ticks_per_col * 4;
            }

            // Scroll moves the viewport without changing the cursor
            Action::ScrollUp => {
                state.scroll_track = state.scroll_track.saturating_sub(1);
            }
            Action::ScrollDown => {
                if track_count > 0 {
                    state.scroll_track = (state.scroll_track + 1).min(track_count.saturating_sub(1));
                }
            }
            Action::ScrollLeft => {
                state.scroll_tick = state.scroll_tick.saturating_sub(state.ticks_per_col * 16);
            }
            Action::ScrollRight => {
                state.scroll_tick += state.ticks_per_col * 16;
            }

            // Horizontal zoom: halve/double ticks_per_col, clamped
            Action::ZoomInH => {
                state.ticks_per_col = (state.ticks_per_col / 2).max(MIN_TICKS_PER_COL);
            }
            Action::ZoomOutH => {
                state.ticks_per_col = (state.ticks_per_col * 2).min(MAX_TICKS_PER_COL);
            }

            // Vertical zoom: grow/shrink track row height, clamped
            Action::ZoomInV => {
                state.track_height = (state.track_height + 1).min(MAX_TRACK_HEIGHT);
            }
            Action::ZoomOutV => {
                state.track_height = (state.track_height - 1).max(MIN_TRACK_HEIGHT);
            }

            Action::TogglePlay => {
                state.playing = !state.playing;
            }

            Action::RenameTrack => {
                if state.project.is_some() {
                    state.mode = Mode::Command;
                    state.command_input = "rename ".to_string();
                }
            }

            Action::AddTrack => {
                let project = state.project.get_or_insert_with(|| Box::new(Project::default()));
                let number = project.tracks.len() as u32 + 1;
                let track = Track::new(format!("Track {number}"), number);
                let insert_at = if project.tracks.is_empty() {
                    0
                } else {
                    state.cursor_track + 1
                };
                project.tracks.insert(insert_at, track);
                state.cursor_track = insert_at;
            }

            Action::DeleteTrack => {
                if let Some(project) = &mut state.project {
                    if !project.tracks.is_empty() {
                        project.tracks.remove(state.cursor_track);
                        if !project.tracks.is_empty() {
                            state.cursor_track = state.cursor_track.min(project.tracks.len() - 1);
                        } else {
                            state.cursor_track = 0;
                        }
                    }
                }
            }
        }
    }

    fn execute_command(&mut self, cmd: &str) {
        let mut parts = cmd.splitn(2, ' ');
        match parts.next().unwrap_or("") {
            "q" | "quit" => self.should_quit = true,
            "new" => {
                let name = parts.next().unwrap_or("Untitled");
                self.state.project = Some(Box::new(Project::new(name)));
                self.state.cursor_track = 0;
                self.state.scroll_track = 0;
                self.state.scroll_tick = 0;
                self.project_path = None;
                self.state.status_message = Some(format!("created project \"{name}\""));
            }
            "w" => {
                let path = parts.next()
                    .map(std::path::PathBuf::from)
                    .or_else(|| self.project_path.clone());
                match path {
                    Some(p) => self.save_project(&p),
                    None => self.state.status_message = Some("usage: w <path>".into()),
                }
            }
            "rename" => {
                match parts.next() {
                    Some(name) if !name.is_empty() => {
                        if let Some(project) = &mut self.state.project {
                            if let Some(track) = project.tracks.get_mut(self.state.cursor_track) {
                                track.name = name.to_string();
                                self.state.status_message = Some(format!("renamed to \"{name}\""));
                            }
                        }
                    }
                    _ => self.state.status_message = Some("usage: rename <name>".into()),
                }
            }
            "e" | "edit" => {
                match parts.next() {
                    Some(path) => self.load_project(std::path::Path::new(path)),
                    None => self.state.status_message = Some("usage: e <path>".into()),
                }
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
