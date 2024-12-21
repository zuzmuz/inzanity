import Foundation
import SwiftTUI
import SwiftyLua

struct ApplicationView: View {
    @ObservedObject var project: Project
    var body: some View {
        VStack {
            TransportView(transport: project.transport)
            Divider()
            ArrangerView(transport:project.transport,
                         trackList: project.trackList,
                         tempoTrack: project.tempoTrack)
        }
    }
}

let config = EnvironmentConfig(luaVM: LuaVM())
let project = Project(id: UUID(), config: config)
let eventHandler = EventHandler(config: config)
let app = Application(rootView: ApplicationView(
        project: project
    ).environment(\.config, config)) { keyPress in

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
app.start()
