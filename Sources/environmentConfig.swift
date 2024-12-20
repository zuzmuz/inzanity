import SwiftyLua
import SwiftTUI
import Foundation

struct EnvironmentConfig {

    enum Key: String {
        case transportIcons = "transport_icons"
        case timeSignature = "time_signature"
        case tempo = "tempo"
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

    struct TimeSignature {
        let numerator: UInt16
        let denominator: UInt16

        init(from lua: Table? = nil) {
            let timeSignature = lua?[Key.timeSignature.rawValue] as? Table
            numerator = timeSignature?[1]as? UInt16 ?? 4
            denominator = timeSignature?[2] as? UInt16 ?? 4
            #warning("Consider validating lua configs whith good warning messages")
        }
    }

    struct Tempo {
        let bpm: Double

        init(from lua: Table? = nil) {
            bpm = lua?[Key.tempo.rawValue] as? Double ?? 120
        }
    }

    var transportIcons = TransportIcons()
    var timeSignature = TimeSignature()
    var tempo = Tempo()

    init() {}

    init(luaVM: LuaVM) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let url = home.appending(path: ".inzanity/config/init.lua")
            do {
                switch try luaVM.execute(url: url) {
                    case let .values(values):
                        guard let configTable = values.first as? Table else {
                            log("Error: main.lua must return a table")
                            return
                        }
                        transportIcons = TransportIcons(from: configTable[Key.transportIcons.rawValue] as? Table)
                        timeSignature = TimeSignature(from: configTable[Key.timeSignature.rawValue] as? Table)
                        tempo = Tempo(from: configTable[Key.tempo.rawValue] as? Table)
                case let .error(error): 
                    log("Lua Error: \(error)")
                }
            } catch {
                log("Error: \(error)")
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
