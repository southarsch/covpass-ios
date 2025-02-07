//
//  Test.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class Test: Codable {
    /// Disease or agent targeted
    public var tg: String
    /// Type of Test
    public var tt: String
    /// Test name (optional for NAAT test)
    public var nm: String?
    /// Test manufacturer (optional for NAAT test)
    public var ma: String?
    /// Date/Time of Sample Collection
    public var sc: Date
    /// Test Result
    public var tr: String
    /// Testing Centre
    public var tc: String
    /// Country of Vaccination
    public var co: String
    /// Certificate Issuer
    public var `is`: String
    /// Unique Certificate Identifier: UVCI
    public var ci: String

    /// True if test result is from a PCR test
    public var isPCR: Bool {
        tt == "LP6464-4"
    }

    /// True if test result is from a Antigen test
    public var isAntigen: Bool {
        tt == "LP217198-3"
    }

    /// True if test is positive
    public var isPositive: Bool {
        tr == "260373001"
    }

    /// True if test is valid
    /// PCR <= 72 hours
    /// Rapid <= 48 hours
    public var isValid: Bool {
        let hours = isPCR ? 72 : 48
        if let validUntil = Calendar.current.date(byAdding: .hour, value: hours, to: sc) {
            return Date() <= validUntil
        }
        return false
    }

    enum CodingKeys: String, CodingKey {
        case tg
        case tt
        case nm
        case ma
        case sc
        case dr
        case tr
        case tc
        case co
        case `is`
        case ci
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tg = try values.decode(String.self, forKey: .tg)
        tt = try values.decode(String.self, forKey: .tt)
        nm = try? values.decode(String.self, forKey: .nm)
        ma = try? values.decode(String.self, forKey: .ma)
        guard let scDateString = try? values.decode(String.self, forKey: .sc),
              let scDate = DateUtils.parseDate(scDateString)
        else {
            throw ApplicationError.missingData("Value is missing for Test.sc")
        }
        sc = scDate
        tr = try values.decode(String.self, forKey: .tr)
        tc = try values.decode(String.self, forKey: .tc)
        co = try values.decode(String.self, forKey: .co)
        `is` = try values.decode(String.self, forKey: .is)
        ci = try values.decode(String.self, forKey: .ci)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tg, forKey: .tg)
        try container.encode(tt, forKey: .tt)
        try container.encode(nm, forKey: .nm)
        try container.encode(ma, forKey: .ma)
        let scDate = DateUtils.isoDateTimeFormatter.string(from: sc)
        try container.encode(scDate, forKey: .sc)
        try container.encode(tr, forKey: .tr)
        try container.encode(tc, forKey: .tc)
        try container.encode(co, forKey: .co)
        try container.encode(`is`, forKey: .is)
        try container.encode(ci, forKey: .ci)
    }

    public func map(key: String?, from json: URL?) -> String? {
        guard let key = key,
              let jsonUrl = json,
              let jsonData = try? Data(contentsOf: jsonUrl) else { return nil }

        guard let rules = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let valueSet = rules["valueSetValues"] as? [String: Any],
              let value = valueSet[key] as? [String: Any] else { return nil }

        return value["display"] as? String
    }
}
