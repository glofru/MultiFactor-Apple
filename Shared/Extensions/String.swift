//
//  String.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }

    static func random(length: Int = 32) -> String {
        let characters = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()-=[];',./_+{}:|<>?"
        var result = ""
        for _ in 0..<length {
            let index = Int.random(in: 0..<characters.count)
            result += characters[index]
        }
        return result
    }
}
