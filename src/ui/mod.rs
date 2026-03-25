pub mod arrangement;
pub mod command_bar;
pub mod theme;
pub mod transport;

use ratatui::{
    Frame,
    layout::{Constraint, Direction, Layout},
};

use crate::app::AppState;
use crate::ui::{
    arrangement::ArrangementView,
    command_bar::CommandBar,
    theme::Theme,
    transport::TransportBar,
};

pub fn render(frame: &mut Frame, state: &AppState, theme: &Theme) {
    let areas = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(1), // transport
            Constraint::Fill(1),   // arrangement
            Constraint::Length(1), // command bar
        ])
        .split(frame.area());

    frame.render_widget(
        TransportBar {
            tempo: state.project.as_ref().map(|p| p.tempo).unwrap_or_default(),
            playing: state.playing,
            position_secs: 0.0,
        },
        areas[0],
    );

    frame.render_widget(
        ArrangementView {
            project: state.project.as_deref(),
            cursor_track: state.cursor_track,
            scroll_tick: state.scroll_tick,
            ticks_per_col: state.ticks_per_col,
        },
        areas[1],
    );

    frame.render_widget(
        CommandBar {
            mode: state.mode,
            command_input: &state.command_input,
            status_message: state.status_message.as_deref(),
            theme,
        },
        areas[2],
    );
}
