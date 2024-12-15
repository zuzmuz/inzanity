import SwiftTUI

struct TransportState {
    var currentCursorPosition: Double = 0
    var startCursorPosition: Double = 0
    var loopStartPosition: Double = 0
    var loopEndPosition: Double = 0
    var isPlaying: Bool = false
    var isRecording: Bool = false
    var isLooping: Bool = false
}

// struct TransportStateKey: EnvironmentKey {
//     static let defaultValue: Binding<TransportState> = .init(get: { .init() }, set: { defaultValue in 
//         log("TransportStateKey.defaultValue.set \(defaultValue)")
//     })
// }
//
// extension EnvironmentValues {
//     var transportState: Binding<TransportState> {
//         get { self[TransportStateKey.self] }
//         set { self[TransportStateKey.self] = newValue }
//     }
// }
