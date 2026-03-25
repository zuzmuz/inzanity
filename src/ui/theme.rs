use ratatui::style::Color;

pub struct Theme {
    pub bg: Color,
    pub fg: Color,
    pub accent: Color,
    pub muted: Color,
    pub track_colors: [Color; 8],
    pub mode_normal: Color,
    pub mode_insert: Color,
    pub mode_visual: Color,
    pub mode_command: Color,
}

impl Default for Theme {
    fn default() -> Self {
        Self {
            bg: Color::Reset,
            fg: Color::White,
            accent: Color::Cyan,
            muted: Color::DarkGray,
            track_colors: [
                Color::Cyan,
                Color::Green,
                Color::Yellow,
                Color::Magenta,
                Color::Red,
                Color::Blue,
                Color::LightCyan,
                Color::LightGreen,
            ],
            mode_normal: Color::Cyan,
            mode_insert: Color::Green,
            mode_visual: Color::Magenta,
            mode_command: Color::Yellow,
        }
    }
}

impl Theme {
    pub fn mode_color(&self, mode: &crate::state::mode::Mode) -> Color {
        use crate::state::mode::Mode;
        match mode {
            Mode::Normal => self.mode_normal,
            Mode::Insert => self.mode_insert,
            Mode::Visual => self.mode_visual,
            Mode::Command => self.mode_command,
        }
    }
}
