//
//  Array+Extensions.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/21/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
