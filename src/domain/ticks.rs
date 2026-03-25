/// Internal tick resolution: 2^20 ticks per beat.
pub const TICKS_PER_BEAT: u64 = 1_048_576;

/// An absolute position in the timeline, measured in ticks.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Default, serde::Serialize, serde::Deserialize)]
pub struct Tick(pub u64);

/// A duration measured in ticks.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Default, serde::Serialize, serde::Deserialize)]
pub struct TickDuration(pub u64);

/// Beats per minute.
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd, serde::Serialize, serde::Deserialize)]
pub struct Bpm(pub f64);

/// Beats per second. Project files store tempo in this unit (e.g. `2.0` = 120 BPM).
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd, serde::Serialize, serde::Deserialize)]
pub struct Tempo(pub f64);

impl Tempo {
    pub fn to_bpm(self) -> Bpm {
        Bpm(self.0 * 60.0)
    }
}

impl Bpm {
    pub fn to_tempo(self) -> Tempo {
        Tempo(self.0 / 60.0)
    }
}

impl Default for Tempo {
    fn default() -> Self {
        Tempo(2.0) // 120 BPM
    }
}

/// Convert a beat position (fractional) to a tick.
pub fn beat_to_tick(beat: f64) -> Tick {
    Tick((beat * TICKS_PER_BEAT as f64).round() as u64)
}

/// Convert a tick to a beat position.
pub fn tick_to_beat(tick: Tick) -> f64 {
    tick.0 as f64 / TICKS_PER_BEAT as f64
}

/// Convert a tick position to seconds given a constant tempo.
pub fn ticks_to_seconds(tick: Tick, tempo: Tempo) -> f64 {
    tick_to_beat(tick) / tempo.0
}

/// Convert seconds to a tick position given a constant tempo.
pub fn seconds_to_tick(seconds: f64, tempo: Tempo) -> Tick {
    beat_to_tick(seconds * tempo.0)
}

impl std::ops::Add<TickDuration> for Tick {
    type Output = Tick;
    fn add(self, rhs: TickDuration) -> Tick {
        Tick(self.0 + rhs.0)
    }
}

impl std::ops::Sub for Tick {
    type Output = TickDuration;
    fn sub(self, rhs: Tick) -> TickDuration {
        TickDuration(self.0.saturating_sub(rhs.0))
    }
}
