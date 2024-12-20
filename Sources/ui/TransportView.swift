import SwiftTUI

struct TransportView: View {
    @Environment(\.config.transportIcons) var icons: EnvironmentConfig.TransportIcons
    @ObservedObject var transport: Transport

    var body: some View {
        HStack {
            Button(transport.playing ? icons.pause : icons.play) {
                transport.playing.toggle()
            }
            Button(icons.stop) {
                log("stop pressed")
                transport.playing = false
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
