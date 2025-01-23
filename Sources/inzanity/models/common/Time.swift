import Foundation

protocol EventItem {
    var position: Tick { get set }
}

protocol BoundedEventItem: EventItem {
    var duration: Tick { get set }
}

struct Denominator: Codable {
    var value: UInt16
    
    static let eighth = Denominator(value: 8)
    static let quarter = Denominator(value: 4)
    static let dottedQuarter = Denominator(value: 3)
    static let half = Denominator(value: 2)
    static let whole = Denominator(value: 1)
}

struct Tempo: Codable, Comparable {
    var nanosecondsPerTick: UInt64

    func bpm(denominator: Denominator) -> Double {
        60 / seconds(per: denominator)
    }

    func seconds(per denominator: Denominator) -> TimeInterval {
        Double(nanosecondsPerTick * Tick.ticksPerWholeNote / UInt64(denominator.value))/1_000_000_000
    }

    init(seconds: TimeInterval, denominator: Denominator) {
        self.nanosecondsPerTick = UInt64(seconds * 1_000_000_000 / Double(Tick.ticksPerWholeNote) * Double(denominator.value))
    }

    init(bpm: Double, denominator: Denominator) {
        self.init(seconds: 60 / bpm, denominator: denominator)
    }

    static func < (lhs: Tempo, rhs: Tempo) -> Bool {
        lhs.nanosecondsPerTick < rhs.nanosecondsPerTick
    }
}


struct Tick: Codable, Comparable, Hashable {
    static let ticksPerWholeNote: UInt64 = 1 << 20
    
    var value: UInt64

    var wholeNotes: Double {
        Double(value) / Double(Tick.ticksPerWholeNote)
    }

    func beats(denominator: UInt16) -> UInt64 {
        #warning("might lose precision if denominator if not a power of 2")
        // NOTE: if value is .max or close to it can't multiply by denominator
        return value / (Tick.ticksPerWholeNote / UInt64(denominator))
    }

    func seconds(with tempo: Tempo) -> TimeInterval {
        return Double(self.value) / Double(tempo.nanosecondsPerTick)
    }

    static func < (lhs: Tick, rhs: Tick) -> Bool {
        lhs.value < rhs.value
    }

    static func + (lhs: Tick, rhs: Tick) -> Tick {
        Tick(value: lhs.value + rhs.value)
    }

    static func - (lhs: Tick, rhs: Tick) -> Tick {
        Tick(value: lhs.value - rhs.value)
    }
}
