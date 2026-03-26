use ratatui::{
    buffer::Buffer,
    layout::{Constraint, Layout, Direction, Rect},
    style::{Color, Modifier, Style},
    text::Line,
    widgets::Widget,
};

use crate::domain::{project::Project, ticks::TICKS_PER_BEAT};
use crate::state::panel::Panel;

const TRACK_NAME_WIDTH: u16 = 20;

pub struct ArrangementView<'a> {
    pub project: Option<&'a Project>,
    pub cursor_track: usize,
    pub scroll_track: usize,
    pub scroll_tick: u64,
    pub ticks_per_col: u64,
    pub track_height: u16,
    pub focused_panel: Panel,
}

impl Widget for ArrangementView<'_> {
    fn render(self, area: Rect, buf: &mut Buffer) {
        if area.height == 0 {
            return;
        }

        let cols = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Length(TRACK_NAME_WIDTH), Constraint::Fill(1)])
            .split(area);

        let name_area = cols[0];
        let timeline_area = cols[1];

        // Render header row
        let header_rect = Rect { height: 1, ..name_area };
        let timeline_header_rect = Rect { height: 1, ..timeline_area };
        self.render_header(header_rect, timeline_header_rect, buf);

        if area.height < 2 {
            return;
        }

        let tracks_name_area = Rect { y: name_area.y + 1, height: name_area.height.saturating_sub(1), ..name_area };
        let tracks_timeline_area = Rect { y: timeline_area.y + 1, height: timeline_area.height.saturating_sub(1), ..timeline_area };

        let tracks = self.project.map(|p| p.tracks.as_slice()).unwrap_or(&[]);
        let th = self.track_height;

        for (slot, (i, track)) in tracks.iter().enumerate().skip(self.scroll_track).enumerate() {
            let y_offset = slot as u16 * th;
            if y_offset >= tracks_name_area.height {
                break;
            }

            let is_selected = i == self.cursor_track;
            let row_style = if is_selected {
                Style::default().bg(Color::Rgb(40, 40, 60)).add_modifier(Modifier::BOLD)
            } else {
                Style::default()
            };

            // Clip height to the area boundary so we never write past it
            let area_bottom = tracks_name_area.y + tracks_name_area.height;
            let row_y = tracks_name_area.y + y_offset;
            let clipped_height = th.min(area_bottom.saturating_sub(row_y));

            let name_row = Rect {
                y: row_y,
                height: clipped_height,
                ..tracks_name_area
            };
            let indent = "  ".repeat(track.depth as usize);
            let mute_indicator = if track.mute { "M" } else { " " };
            let solo_indicator = if track.solo { "S" } else { " " };
            let armed_indicator = if track.armed { "●" } else { " " };
            let label = format!(
                "{indent}{armed_indicator}{mute_indicator}{solo_indicator} {name}",
                name = track.name,
            );
            let truncated = truncate_str(&label, TRACK_NAME_WIDTH as usize);
            // Fill all rows of the name cell
            for row in 0..clipped_height {
                let row_y = name_row.y + row;
                if row_y >= tracks_name_area.y + tracks_name_area.height {
                    break;
                }
                let content = if row == 0 {
                    format!("{truncated:<width$}", width = TRACK_NAME_WIDTH as usize)
                } else {
                    " ".repeat(TRACK_NAME_WIDTH as usize)
                };
                buf.set_string(name_row.x, row_y, content, row_style);
            }

            // Timeline rows — same clipping as name area
            let timeline_row = Rect {
                y: tracks_timeline_area.y + y_offset,
                height: clipped_height,
                ..tracks_timeline_area
            };
            self.render_track_items(track, timeline_row, is_selected, i, buf);
        }
    }
}

impl ArrangementView<'_> {
    fn render_header(&self, name_area: Rect, timeline_area: Rect, buf: &mut Buffer) {
        let (track_label_color, beat_marker_color) = match self.focused_panel {
            Panel::TrackList => (Color::Cyan, Color::DarkGray),
            Panel::Arrange  => (Color::DarkGray, Color::Cyan),
        };
        let header_style = Style::default().fg(track_label_color).add_modifier(Modifier::BOLD);
        buf.set_string(name_area.x, name_area.y, format!("{:<width$}", "  TRACKS", width = TRACK_NAME_WIDTH as usize), header_style);

        // Beat markers
        let beats_visible = timeline_area.width as u64;
        for col in 0..beats_visible {
            let tick = self.scroll_tick + col * self.ticks_per_col;
            let beat = tick / TICKS_PER_BEAT;
            let beat_start = beat * TICKS_PER_BEAT;
            // Show marker at beat boundaries
            if tick == beat_start || (col == 0) {
                let label = format!("{}", beat + 1);
                let x = timeline_area.x + col as u16;
                if x + label.len() as u16 <= timeline_area.x + timeline_area.width {
                    buf.set_string(x, timeline_area.y, &label, Style::default().fg(beat_marker_color).add_modifier(Modifier::BOLD));
                }
            }
        }
    }

    fn render_track_items(
        &self,
        track: &crate::domain::track::Track,
        area: Rect,
        selected: bool,
        track_index: usize,
        buf: &mut Buffer,
    ) {
        use crate::domain::item::ItemSource;

        let bg = if selected { Color::Rgb(40, 40, 60) } else { Color::Reset };

        // Fill all rows of this track's block with background
        for row in 0..area.height {
            buf.set_string(area.x, area.y + row, " ".repeat(area.width as usize), Style::default().bg(bg));
        }

        let color_index = track_index % 8;
        let default_theme = crate::ui::theme::Theme::default();
        let item_color = default_theme.track_colors[color_index];

        for item in &track.items {
            let item_start_tick = item.position.0;
            let item_end_tick = item.end_tick().0;
            let view_end_tick = self.scroll_tick + area.width as u64 * self.ticks_per_col;

            // Skip items entirely outside the view
            if item_end_tick <= self.scroll_tick || item_start_tick >= view_end_tick {
                continue;
            }

            let start_col = item_start_tick.saturating_sub(self.scroll_tick) / self.ticks_per_col;
            let end_col = (item_end_tick.saturating_sub(self.scroll_tick) + self.ticks_per_col - 1) / self.ticks_per_col;
            let start_col = start_col.min(area.width as u64) as u16;
            let end_col = end_col.min(area.width as u64) as u16;
            let width = end_col.saturating_sub(start_col);

            if width == 0 {
                continue;
            }

            let label = match &item.source {
                ItemSource::Midi { .. } => "MIDI",
                ItemSource::Audio { path, .. } => {
                    path.rsplit('/').next().unwrap_or("audio")
                }
            };

            let item_style = Style::default().fg(Color::Black).bg(item_color);
            let content = truncate_str(label, width as usize);
            let padded = format!("{content:<width$}", width = width as usize);
            // Draw item across all rows of this track's height
            for row in 0..area.height {
                let row_content = if row == 0 { padded.clone() } else { " ".repeat(width as usize) };
                buf.set_string(area.x + start_col, area.y + row, row_content, item_style);
            }
        }
    }
}

fn truncate_str(s: &str, max: usize) -> String {
    if s.len() <= max {
        s.to_string()
    } else if max == 0 {
        String::new()
    } else {
        format!("{}…", &s[..max.saturating_sub(1)])
    }
}
