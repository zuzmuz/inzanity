import AVFoundation
import Foundation
import SwiftTUI



class AudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()

    var project: Project?

    var bufferSize: AVAudioFrameCount = 128

    init() {
        engine.attach(mixer)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.installTap(
            onBus: 0, bufferSize: bufferSize, format: format
        ) { buffer, time in
            log("time: \(time)")
        }
    }

    func start() {
        do {
            try engine.start()
        } catch {
            log("failed to start engine: \(error)")
        }
    }

    func load(project: Project) {
        project.objectWillChange
    }
}
