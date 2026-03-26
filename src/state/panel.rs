#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum Panel {
    #[default]
    TrackList,
    Arrange,
}

impl std::fmt::Display for Panel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Panel::TrackList => write!(f, "TRACKS"),
            Panel::Arrange => write!(f, "ARRANGE"),
        }
    }
}
