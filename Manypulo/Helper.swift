//
//  Helper.swift
//  ObjectMotion
//
//  Created by Tassilo Bouwman on 07.03.18.
//  Copyright © 2018 Tassilo Bouwman. All rights reserved.
//

import Foundation

extension String {
    var digits: String {
        return trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.-").inverted)
    }
}
