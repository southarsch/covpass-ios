//
//  QRCoder.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import Foundation
import PromiseKit

public enum QRCodeError: Error {
    case qrCodeExists
    case versionNotSupported
}

enum QRCoder {
    static func parse(_ payload: String) -> Promise<CoseSign1Message> {
        return Promise { seal in
            let payload = payload.stripPrefix()
            let base45Decoded = try Base45Coder.decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decode base45 from int casted  QR Code data")
            }
            let cosePayload = try CoseSign1Message(decompressedPayload: decompressedPayload)
            seal.fulfill(cosePayload)
        }
    }
}
