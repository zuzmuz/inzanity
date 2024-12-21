import Foundation
import Yams

extension Project: Codable {
    enum CodingKeys: CodingKey {
        case id, metadata, tempoTrack//, trackList, transport
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            metadata: try container.decode(Metadata.self, forKey: .metadata),
            tempoTrack: try container.decode(TempoTrack.self, forKey: .tempoTrack)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(tempoTrack, forKey: .tempoTrack)
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
            timeSignatureChanges: try container.decode([TimeSignatureChange].self, forKey: .timeSignatureChanges)
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
