use serde::{Deserialize, Serialize};
use uuid::Uuid;

use super::ticks::{Tick, TickDuration};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Item {
    pub id: Uuid,
    pub position: Tick,
    pub duration: TickDuration,
    pub source: ItemSource,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ItemSource {
    Midi {
        /// Raw MIDI event bytes.
        data: Vec<u8>,
    },
    Audio {
        path: String,
        /// Byte offset into the audio file.
        file_offset: u64,
    },
}

impl Item {
    pub fn new_midi(position: Tick, duration: TickDuration, data: Vec<u8>) -> Self {
        Self {
            id: Uuid::new_v4(),
            position,
            duration,
            source: ItemSource::Midi { data },
        }
    }

    pub fn new_audio(position: Tick, duration: TickDuration, path: String) -> Self {
        Self {
            id: Uuid::new_v4(),
            position,
            duration,
            source: ItemSource::Audio { path, file_offset: 0 },
        }
    }

    pub fn end_tick(&self) -> Tick {
        self.position + self.duration
    }
}
