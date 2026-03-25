use ratatui::{
    buffer::Buffer,
    layout::Rect,
    style::{Color, Style},
    text::{Line, Span},
    widgets::Widget,
};

use crate::domain::ticks::Tempo;

pub struct TransportBar {
    pub tempo: Tempo,
    pub playing: bool,
    pub position_secs: f64,
}

impl TransportBar {
    fn format_position(secs: f64) -> String {
        let total = secs as u64;
        let h = total / 3600;
        let m = (total % 3600) / 60;
        let s = total % 60;
        let ms = ((secs.fract()) * 1000.0) as u64;
        format!("{h:02}:{m:02}:{s:02}.{ms:03}")
    }
}

impl Widget for TransportBar {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let status = if self.playing { "▶" } else { "■" };
        let status_color = if self.playing { Color::Green } else { Color::DarkGray };
        let bpm = self.tempo.to_bpm().0;
        let pos = Self::format_position(self.position_secs);

        let line = Line::from(vec![
            Span::styled(format!(" {status} "), Style::default().fg(status_color)),
            Span::styled("│ ", Style::default().fg(Color::DarkGray)),
            Span::styled(format!("{bpm:.1} BPM"), Style::default().fg(Color::White)),
            Span::styled("  │  ", Style::default().fg(Color::DarkGray)),
            Span::styled(pos, Style::default().fg(Color::White)),
        ]);

        line.render(area, buf);
    }
}
