use anyhow::Result;
use crossterm::event::{Event, KeyCode, KeyEvent, KeyModifiers};
use ratatui::{
    Frame,
    layout::{Alignment, Constraint, Direction, Layout},
    style::{Color, Style},
    widgets::{Block, Borders, Paragraph},
};

pub struct App {
    pub should_quit: bool,
}

impl App {
    pub fn new() -> Self {
        Self { should_quit: false }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        if let Event::Key(KeyEvent { code, modifiers, .. }) = event {
            match (code, modifiers) {
                (KeyCode::Char('c'), KeyModifiers::CONTROL) => self.should_quit = true,
                (KeyCode::Char('q'), _) => self.should_quit = true,
                _ => {}
            }
        }
        Ok(())
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
            Paragraph::new("  q  quit")
                .style(Style::default().fg(Color::DarkGray)),
            areas[1],
        );
    }
}
