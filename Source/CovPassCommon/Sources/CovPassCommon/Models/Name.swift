//
//  Name.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class Name: Codable {
    /// The given name(s) of the person addressed in the certificate
    public var gn: String?
    /// The family or primary name(s) of the person addressed in the certificate
    public var fn: String?
    /// The given name(s) of the person transliterated
    public var gnt: String?
    /// The family name(s) of the person transliterated
    public var fnt: String

    /// The full name of the person
    public var fullName: String {
        if let gn = gn, let fn = fn {
            return "\(gn) \(fn)"
        }
        if let gnt = gnt {
            return"\(gnt) \(fnt)"
        }
        return fnt
    }
    public var fullNameReverse: String {
        if let gn = gn, let fn = fn {
            return "\(fn) \(gn)"
        }
        if let gnt = gnt {
            return"\(fnt) \(gnt)"
        }
        return fnt
    }

    enum CodingKeys: String, CodingKey {
        case gn
        case fn
        case gnt
        case fnt
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gn = try? values.decode(String.self, forKey: .gn)
        fn = try? values.decode(String.self, forKey: .fn)
        gnt = try? values.decode(String.self, forKey: .gnt)
        fnt = try values.decode(String.self, forKey: .fnt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gn, forKey: .gn)
        try container.encode(fn, forKey: .fn)
        try container.encode(gnt, forKey: .gnt)
        try container.encode(fnt, forKey: .fnt)
    }
}

extension Name: Equatable {
    public static func == (lhs: Name, rhs: Name) -> Bool {
        return lhs.fullName == rhs.fullName
    }
}
