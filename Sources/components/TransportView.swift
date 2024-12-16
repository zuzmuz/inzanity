import SwiftTUI

struct TransportView: View {
    @Environment(\.config.transportIcons) var icons: EnvironmentConfig.TransportIcons
    @Binding var state: TransportState

    var body: some View {
        HStack {
            Button(state.isPlaying ? icons.pause : icons.play) {
                log("play pressed \(state.isPlaying)")
                state.isPlaying.toggle()
            }
            Button(icons.stop) {
                log("stop pressed")
                state.isPlaying = false
            }
            Button(icons.record) {
                log("record pressed")
            }
            Button(icons.loop) {
                log("loop pressed")
            }
        }
    }
}
