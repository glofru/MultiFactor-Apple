//
//  String+Subscript.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

import Foundation

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
