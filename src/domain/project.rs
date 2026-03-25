use serde::{Deserialize, Serialize};

use super::ticks::Tempo;
use super::track::Track;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Project {
    pub name: String,
    pub tempo: Tempo,
    pub tracks: Vec<Track>,
}

impl Project {
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            tempo: Tempo::default(),
            tracks: Vec::new(),
        }
    }
}

impl Default for Project {
    fn default() -> Self {
        Self::new("Untitled")
    }
}
