//
//  isDebug.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import Foundation


func isDebug() -> Bool {
    #if DEBUG
    return true
#else
    return false
#endif
}
