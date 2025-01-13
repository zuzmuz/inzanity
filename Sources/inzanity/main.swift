import Foundation
import SwiftTUI
import SwiftyLua
import logger

struct ApplicationView: View {
    @ObservedObject var project: Project
    var body: some View {
        VStack {
            TransportView(transport: project.transport)
            Divider()
            ArrangerView(
                transport: project.transport,
                trackList: project.trackList,
                tempoTrack: project.tempoTrack)
        }
    }
}
let logger = FileLogger()
let config = EnvironmentConfig(luaVM: LuaVM())
let project = Project(
    id: UUID(),
    metadata: .init(
        name: "masterpiece",
        author: "zaher",
        description: "a masterpiece",
        createdDate: Date(),
        changedDate: Date()),
    tempoTrack: TempoTrack(
        tempoChanges: [
            TempoChange(position: 0, bpm: 120)
            // TempoChange(position: 100, bpm: 140),
        ],
        timeSignatureChanges: [
            TimeSignatureChange(position: 0, numerator: 4, denominator: 4)
            // TimeSignatureChange(position: 100, numerator: 3, denominator: 4),
        ]),
    trackList: TrackList(tracks: [
        Track(
            id: UUID(), number: 1, name: "track 1",
            items: [
                .init(
                    position: ticksPerWholeNote, duration: 4 * ticksPerWholeNote,
                    source: .midi(MidiItem(midiData: Data([0x90, 0x40, 0x7f])))),
                .init(
                    position: 6 * ticksPerWholeNote, duration: 2 * ticksPerWholeNote,
                    source: .midi(MidiItem(midiData: Data([0x90, 0x40, 0x7f])))),
                .init(
                    position: 10 * ticksPerWholeNote, duration: 4 * ticksPerWholeNote,
                    source: .midi(MidiItem(midiData: Data([0x90, 0x40, 0x7f])))),
            ]),
        Track(
            id: UUID(), number: 2, name: "track 2",
            items: [
                .init(
                    position: 0, duration: 10 * ticksPerWholeNote,
                    source: .audio(
                        AudioItem(fileLocation: "audio.mp3", positionInFile: TimeInterval(1))))
            ]),
    ]))
let eventHandler = EventHandler(config: config)
let app = Application(
    rootView: ApplicationView(
        project: project
    ).environment(\.config, config)
) { keyPress in

    let event = eventHandler.handle(keyPress: keyPress)

    switch event {
    case .propagate(let keyPress):
        return .propagate(keyPress: keyPress)
    case let .horizontalZoomIn(motion):
        project.transport.horizontalZoom += motion
    case let .horizontalZoomOut(motion):
        if project.transport.horizontalZoom > motion {
            project.transport.horizontalZoom -= motion
        }
    case let .horizontalOffsetLeft(motion):
        project.transport.modifyHorizontalOffset(by: Int16(motion))
    case let .horizontalOffsetRight(motion):
        project.transport.modifyHorizontalOffset(by: -Int16(motion))
    default:
        break
    }

    return .consume
}

let audioEngine = AudioEngine()

try! project.save(to: URL(fileURLWithPath: "project.yml"))
app.start()
