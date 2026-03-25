use anyhow::Result;
use crossterm::event::{Event, KeyEvent};
use ratatui::{
    Frame,
    layout::{Alignment, Constraint, Direction, Layout},
    style::{Color, Style},
    widgets::{Block, Borders, Paragraph},
};

use crate::config::keybindings::{Action, KeyMap};
use crate::state::mode::Mode;

pub struct App {
    pub should_quit: bool,
    pub mode: Mode,
    keymap: KeyMap,
}

impl App {
    pub fn new() -> Self {
        Self {
            should_quit: false,
            mode: Mode::default(),
            keymap: KeyMap::default_bindings(),
        }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        if let Event::Key(KeyEvent { code, modifiers, .. }) = event {
            if let Some(action) = self.keymap.get(self.mode, code, modifiers) {
                self.handle_action(action);
            }
        }
        Ok(())
    }

    fn handle_action(&mut self, action: Action) {
        match action {
            Action::Quit => self.should_quit = true,
            Action::EnterCommand => self.mode = Mode::Command,
            Action::EnterInsert => self.mode = Mode::Insert,
            Action::EnterVisual => self.mode = Mode::Visual,
            Action::ExitMode => self.mode = Mode::Normal,
            _ => {}
        }
    }

    pub fn render(&self, frame: &mut Frame) {
        let areas = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Fill(1), Constraint::Length(1)])
            .split(frame.area());

        frame.render_widget(
            Block::default()
                .title(" inzanity ")
                .title_alignment(Alignment::Center)
                .borders(Borders::ALL)
                .style(Style::default().fg(Color::DarkGray)),
            areas[0],
        );

        frame.render_widget(
            Paragraph::new(format!("  {}  |  q quit  |  : command", self.mode))
                .style(Style::default().fg(Color::DarkGray)),
            areas[1],
        );
    }
}
