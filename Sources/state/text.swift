import SwiftTUI

struct TransportIcons {
    let play: String = "▶"
    let pause: String = "⏸"
    let stop: String = "⏹"
    let record: String = "⏺"
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
