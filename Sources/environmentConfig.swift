import SwiftyLua
import SwiftTUI

struct TransportIcons {
    enum Icon: String {
        case play = "play"
        case pause = "pause"
        case stop = "stop"
        case record = "record"
        case loop = "loop"

        func icon(from lua: Table? = nil) -> String {
            if let icon = lua?[self.rawValue] as? String {
                return icon
            }
            return switch self {
                case .play: "▶"
                case .pause: "⏸"
                case .stop: "⏹"
                case .record: "⏺"
                case .loop: "↻"
            }
        }
    }
    let play: String
    let pause: String
    let stop: String
    let record: String
    let loop: String

    init(from lua: Table? = nil) {
        play = Icon.play.icon(from: lua)
        pause = Icon.pause.icon(from: lua)
        stop = Icon.stop.icon(from: lua)
        record = Icon.record.icon(from: lua)
        loop = Icon.loop.icon(from: lua)
    }
}

private struct TransportIconsKey: EnvironmentKey {
    static let defaultValue: TransportIcons = .init()
}

extension EnvironmentValues {
    var transportIcons: TransportIcons {
        get { self[TransportIconsKey.self] }
        set { self[TransportIconsKey.self] = newValue }
    }
}
