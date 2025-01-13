import Foundation


typealias Ticks = UInt64
typealias SecondsPerWholeNote = Double
typealias WholeNotes = Double

let ticksPerWholeNote: Ticks = 1 << 20

extension UInt64 {
    func beats(denominator: UInt16) -> UInt64 {
        (self / ticksPerWholeNote) * UInt64(denominator)
    }
}

func time(from position: Ticks, with tempo: SecondsPerWholeNote) -> TimeInterval {
    return tempo * TimeInterval(position) / TimeInterval(ticksPerWholeNote)
}

protocol EventItem {
    var position: Ticks { get set }
}

protocol BoundedEventItem: EventItem {
    var duration: Ticks { get set }
}
