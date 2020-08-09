//
//  Bundle+Extension.swift
//  ImageTesting
//
//  Created by savana kranth on 09/08/2020.
//  Copyright © 2020 savana kranth. All rights reserved.
//

import Foundation

extension Bundle {
    var isProduction : Bool {
        #if DEBUG
            return false
        #else
            guard let path = self.appStoreReceiptURL?.path else {
                return true
            }
            return !path.contains("sandboxReceipt")
        #endif
    }
}
