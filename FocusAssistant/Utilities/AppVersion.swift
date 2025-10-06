//
//  AppVersion.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import Foundation

func AppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }
