import Foundation

class TrackList: ObservableObject {
    @Published var tracks: [Track] = []
}

class Track: Identifiable, ObservableObject {

    struct MidiItem: BoundedEventItem {
        var position: Tick
        var duration: Tick
    }
    struct AudioItem: BoundedEventItem {
        var position: Tick
        var duration: Tick
        var channels: UInt8
    }
    struct AutomationItem: BoundedEventItem {
        var position: Tick
        var duration: Tick
        var value: Double
    }
    enum Item {
        case midi(MidiItem)
        case audio(AudioItem)
        case automation(AutomationItem)
    }

    let id: UUID
    @Published var number: UInt
    @Published var name: String
    @Published var depth: Int = 0
    @Published var muted: Bool = false
    @Published var solo: Bool = false
    @Published var armed: Bool = false
    @Published var volume: Double = 0.0
    @Published var pan: Double = 0.0
    @Published var fxChain: FxChain = .init()
    @Published var items: [Item] = []

    init(id: UUID, number: UInt, name: String) {
        self.id = id
        self.number = number
        self.name = name
    }
}

// extension Track: Codable {
//     enum CodingKeys: String, CodingKey {
//         case id, number, name, depth, muted, solo, armed, volume, pan, fxChain, items
//     }
//     required init(from decoder: Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         id = try container.decode(UUID.self, forKey: .id)
//         number = try container.decode(UInt.self, forKey: .number)
//         name = try container.decode(String.self, forKey: .name)
//         depth = try container.decode(Int.self, forKey: .depth)
//         muted = try container.decode(Bool.self, forKey: .muted)
//         solo = try container.decode(Bool.self, forKey: .solo)
//         armed = try container.decode(Bool.self, forKey: .armed)
//         volume = try container.decode(Double.self, forKey: .volume)
//         pan = try container.decode(Double.self, forKey: .pan)
//         // fxChain = try container.decode(FxChain.self, forKey: .fxChain)
//         // items = try container.decode([Item].self, forKey: .items)
//     }
//     
//     func encode(to encoder: Encoder) throws {
//         fatalError("Not implemented")
//     }
// }
//
struct FxChain {
    var bypassed: Bool = false
    var plugins: [Plugin] = []
}

protocol Plugin {}
