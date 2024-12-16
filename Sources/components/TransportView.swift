import SwiftTUI

struct TransportView: View {
    @Environment(\.transportIcons) var icons: TransportIcons
    @Binding var state: TransportState

    var body: some View {
        HStack {
            Button(state.isPlaying ? icons.pause : icons.play) {
                log("play pressed \(state.isPlaying)")
                state.isPlaying = !state.isPlaying
            }
            Button(icons.stop) {
                log("stop pressed")
            }
            Button(icons.record) {
                log("record pressed")
            }
        }
    }
}
