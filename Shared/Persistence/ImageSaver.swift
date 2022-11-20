//
//  ImageSaver.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 2022-11-19.
//

import SwiftUI

class ImageSaver: NSObject {

    private var onCompleted: ((Result) -> Void)? = nil

    func saveQRInLibrary(text: String, onCompleted: @escaping (Result) -> Void) {
        if let image = text.qrCode {
            self.onCompleted = onCompleted // I know it sucks a bit... Just let me know if you know better implementations.
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        } else {
            onCompleted(.qrGenerationFailed)
        }
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError: Error?, contextInfo: UnsafeRawPointer) {
        if didFinishSavingWithError != nil {
            self.onCompleted?(.savingFailed)
        } else {
            self.onCompleted?(.success)
        }
    }

    enum Result: Identifiable {
        case success
        case qrGenerationFailed
        case savingFailed

        var id: UUID {
            UUID()
        }
    }
}
