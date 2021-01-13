//
//  ImageSaver.swift
//  EP Calipers
//
//  Created by David Mann on 1/12/21.
//  Copyright © 2021 EP Studios. All rights reserved.
//

import UIKit
import AudioToolbox
import os.log

// Helper class to allow saving images to Photo Album.
@objc class ImageSaver: NSObject {
    var viewController: UIViewController?

    @objc func writeToPhotoAlbum(image: UIImage, viewController: UIViewController) {
        self.viewController = viewController
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(showSavedImageResult), nil)
    }

    @objc func showSavedImageResult(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let title: String
        let message: String
        if let error = error {
            os_log("Error saving snapshot:  %s", log: .errors, type: .error,   error.localizedDescription)
            title = Translation.translatedKey("Save_snapshot_error_title")
            message = Translation.translatedKey("Save_snapshot_error_message")
        } else {
            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
            // See https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library
            os_log("Snapshot successfully saved.", log: .action, type: .info)
            title = Translation.translatedKey("Snapshot_saved_title")
            message = Translation.translatedKey("Snapshot_saved_message")
        }
        if let viewController = viewController {
            showMessage(viewController: viewController, title: title, message: message)
        }
    }

    func showMessage(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Translation.translatedKey("OK"), style: .cancel, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
}

extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier!

    static let viewCycle = OSLog(subsystem: OSLog.subsystem, category: "viewcycle")
    static let action = OSLog(subsystem: OSLog.subsystem, category: "actions")
    static let debugging = OSLog(subsystem: OSLog.subsystem, category: "debugging")
    static let touches = OSLog(subsystem: OSLog.subsystem, category: "touches")
    static let errors = OSLog(subsystem: OSLog.subsystem, category: "errors")
    static let hamburgerCycle = OSLog(subsystem: subsystem, category: "hamburger")
    static let lifeCycle = OSLog(subsystem: subsystem, category: "lifecycle")
    static let test = OSLog(subsystem: subsystem, category: "test")
}
