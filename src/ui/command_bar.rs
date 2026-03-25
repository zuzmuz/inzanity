use ratatui::{
    buffer::Buffer,
    layout::Rect,
    style::{Modifier, Style},
    text::{Line, Span},
    widgets::Widget,
};

use crate::state::mode::Mode;
use crate::ui::theme::Theme;

pub struct CommandBar<'a> {
    pub mode: Mode,
    pub command_input: &'a str,
    pub status_message: Option<&'a str>,
    pub theme: &'a Theme,
}

impl Widget for CommandBar<'_> {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let mode_color = self.theme.mode_color(&self.mode);

        let line = if self.mode == Mode::Command {
            Line::from(vec![
                Span::styled(
                    format!(" {:^9} ", self.mode),
                    Style::default().fg(ratatui::style::Color::Black).bg(mode_color).add_modifier(Modifier::BOLD),
                ),
                Span::raw(" :"),
                Span::raw(self.command_input),
                Span::styled("█", Style::default().fg(mode_color)), // cursor block
            ])
        } else {
            let right = match self.status_message {
                Some(msg) => Span::raw(format!("  {msg}")),
                None => Span::raw(""),
            };
            Line::from(vec![
                Span::styled(
                    format!(" {:^9} ", self.mode),
                    Style::default().fg(ratatui::style::Color::Black).bg(mode_color).add_modifier(Modifier::BOLD),
                ),
                right,
            ])
        };

        line.render(area, buf);
    }
}
