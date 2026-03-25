use serde::{Deserialize, Serialize};
use uuid::Uuid;

use super::item::Item;
use super::ticks::Tick;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Track {
    pub id: Uuid,
    pub name: String,
    /// 1-based track number for display.
    pub number: u32,
    /// Nesting depth for folder tracks (0 = top level).
    pub depth: u32,
    pub mute: bool,
    pub solo: bool,
    pub armed: bool,
    pub volume: f32,
    pub pan: f32,
    pub items: Vec<Item>,
}

impl Track {
    pub fn new(name: impl Into<String>, number: u32) -> Self {
        Self {
            id: Uuid::new_v4(),
            name: name.into(),
            number,
            depth: 0,
            mute: false,
            solo: false,
            armed: false,
            volume: 1.0,
            pan: 0.0,
            items: Vec::new(),
        }
    }

    /// Latest end tick across all items, or `Tick(0)` if empty.
    pub fn end_tick(&self) -> Tick {
        self.items.iter().map(|i| i.end_tick()).max().unwrap_or_default()
    }
}
