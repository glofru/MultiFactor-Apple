//
//  String.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

import CoreImage
import UIKit

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

    var qrCode: UIImage? {
        let data = self.data(using: String.Encoding.ascii, allowLossyConversion: false)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")

        guard let qrCodeImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 20, y: 20)),
              let logo = CIImage(image: .init(named: "noBackgroundIcon")!)?.transformed(by: CGAffineTransform(scaleX: 0.25, y: 0.25)) else {
            return nil
        }

        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: qrCodeImage.extent.midX - (logo.extent.size.width / 2), y: qrCodeImage.extent.midY - (logo.extent.size.height / 2))
        combinedFilter.setValue(logo.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(qrCodeImage, forKey: "inputBackgroundImage")

        guard let finalImage = combinedFilter.outputImage else {
            return nil
        }

        let context = CIContext()
        if let image = context.createCGImage(finalImage, from: finalImage.extent) {
            return UIImage(cgImage: image)
        }

        return nil
    }
}
