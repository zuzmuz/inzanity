import Foundation
import Yams

extension Project: Codable {
    enum CodingKeys: CodingKey {
        case id, metadata, tempoTrack, trackList
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            metadata: try container.decode(Metadata.self, forKey: .metadata),
            tempoTrack: try container.decode(TempoTrack.self, forKey: .tempoTrack),
            trackList: try container.decode(TrackList.self, forKey: .trackList)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(tempoTrack, forKey: .tempoTrack)
        try container.encode(trackList, forKey: .trackList)
    }

    func save(to url: URL) throws {
        let encoder = YAMLEncoder()
        let yaml = try encoder.encode(self)
        try yaml.write(to: url, atomically: true, encoding: .utf8)
    }

    static func load(from url: URL) throws -> Project {
        let yaml = try String(contentsOf: url, encoding: .utf8)
        let decoder = YAMLDecoder()
        return try decoder.decode(Project.self, from: yaml)
    }
}

extension Project.Metadata: Codable {
    enum CodingKeys: CodingKey {
        case name, author, createdDate, changedDate, description, tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.changedDate = try container.decode(Date.self, forKey: .changedDate)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if let author = author {
            try container.encode(author, forKey: .author)
        }
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(changedDate, forKey: .changedDate)
        if let description = description {
            try container.encode(description, forKey: .description)
        }
        if let tags = tags {
            try container.encode(tags, forKey: .tags)
        }
    }
}

extension TempoTrack: Codable {
    enum CodingKeys: CodingKey {
        case tempoChanges, timeSignatureChanges
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            tempoChanges: try container.decode([TempoChange].self, forKey: .tempoChanges),
            timeSignatureChanges: try container.decode(
                [TimeSignatureChange].self, forKey: .timeSignatureChanges)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tempoChanges, forKey: .tempoChanges)
        try container.encode(timeSignatureChanges, forKey: .timeSignatureChanges)
    }
}

extension TempoChange: Codable {
    enum CodingKeys: CodingKey {
        case position, tempo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            position: try container.decode(Tick.self, forKey: .position),
            tempo: try container.decode(Double.self, forKey: .tempo)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
        try container.encode(tempo, forKey: .tempo)
    }
}

extension TimeSignatureChange: Codable {
    enum CodingKeys: CodingKey {
        case position, numerator, denominator
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            position: try container.decode(Tick.self, forKey: .position),
            numerator: try container.decode(UInt16.self, forKey: .numerator),
            denominator: try container.decode(UInt16.self, forKey: .denominator)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
        try container.encode(numerator, forKey: .numerator)
        try container.encode(denominator, forKey: .denominator)
    }
}

extension TrackList: Codable {
    enum CodingKeys: CodingKey {
        case tracks
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            tracks: try container.decode([Track].self, forKey: .tracks)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tracks, forKey: .tracks)
    }
}

extension Track: Codable {
    enum CodingKeys: CodingKey {
        case id, number, name, depth, muted, solo, armed, volume, pan, fxChain, items
    }

    convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            number: try container.decode(UInt.self, forKey: .number),
            name: try container.decode(String.self, forKey: .name),
            depth: try container.decode(Int.self, forKey: .depth),
            muted: try container.decode(Bool.self, forKey: .muted),
            solo: try container.decode(Bool.self, forKey: .solo),
            armed: try container.decode(Bool.self, forKey: .armed),
            volume: try container.decode(Double.self, forKey: .volume),
            pan: try container.decode(Double.self, forKey: .pan)
            // fxChain: try container.decode(FxChain.self, forKey: .fxChain),
            // items: try container.decode([Item].self, forKey: .items)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(name, forKey: .name)
        try container.encode(depth, forKey: .depth)
        try container.encode(muted, forKey: .muted)
        try container.encode(solo, forKey: .solo)
        try container.encode(armed, forKey: .armed)
        try container.encode(volume, forKey: .volume)
        try container.encode(pan, forKey: .pan)
        // try container.encode(fxChain, forKey: .fxChain)
        // try container.encode(items, forKey: .items)
    }
}

// extension FxChain: Codable {
//     enum CodingKeys: CodingKey {
//         case bypassed, plugins
//     }
//
//     convenience init(from decoder: Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         self.init(
//             bypassed: try container.decode(Bool.self, forKey: .bypassed),
//             plugins: try container.decode([Plugin].self, forKey: .plugins)
//         )
//     }
//
//     func encode(to encoder: Encoder) throws {
//         var container = encoder.container(keyedBy: CodingKeys.self)
//         try container.encode(bypassed, forKey: .bypassed)
//         try container.encode(plugins, forKey: .plugins)
//     }
// }

