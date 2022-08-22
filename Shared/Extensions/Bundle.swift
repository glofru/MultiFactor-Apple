//
//  Bundle+Extensions.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import SwiftUI

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "MultiFactor"
    }
}
