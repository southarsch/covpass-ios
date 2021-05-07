//
//  Bundle+AppVersion.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension Bundle {
    public func appVersion() -> String {
        guard
            let version = infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = infoDictionary?["CFBundleVersion"] as? String else {
            return "1.0"
        }
        return "\(version) (\(bundleVersion))"
    }
}
