import SwiftyLua
import SwiftTUI
import Foundation

struct EnvironmentConfig {

    enum Key: String {
        case transportIcons = "transport_icons"
    }

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

    var transportIcons: TransportIcons = .init()

    init() {}

    init(luaVM: LuaVM) {
        if let url = URL.init("scripts/main.lua") {
            do {
                switch try luaVM.execute(url: url) {
                    case let .values(values):
                        guard let configTable = values.first as? Table else {
                            log("Error: main.lua must return a table")
                            return
                        }
                        transportIcons = TransportIcons(from: configTable[Key.transportIcons.rawValue] as? Table)
                case let .error(error): 
                    log("Lua Error: \(error)")
                }
            } catch {
                log("Error: \(error)")
            }
        }
    }
}


private struct ConfigKey: EnvironmentKey {
    static let defaultValue: EnvironmentConfig = .init()
}

extension EnvironmentValues {
    var config: EnvironmentConfig {
        get { self[ConfigKey.self] }
        set { self[ConfigKey.self] = newValue }
    }
}
