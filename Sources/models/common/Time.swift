import Foundation


typealias Tick = UInt64
typealias SecondsPerWholeNote = Double

let ticksPerWholeNote: Tick = 1 << 20

extension UInt64 {
    func beats(denominator: UInt16) -> UInt64 {
        (self / ticksPerWholeNote) * UInt64(denominator)
    }
}

func time(from position: Tick, with tempo: SecondsPerWholeNote) -> TimeInterval {
    return tempo * TimeInterval(position) / TimeInterval(ticksPerWholeNote)
}

protocol EventItem {
    var position: Tick { get set }
}

protocol BoundedEventItem: EventItem {
    var duration: Tick { get set }
}
