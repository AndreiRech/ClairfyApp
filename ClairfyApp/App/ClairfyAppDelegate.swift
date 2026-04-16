//
//  ClairfyAppDelegate.swift
//  ClairfyApp
//
//  Necessário para `URLSessionConfiguration.background`: o sistema reactiva a app
//  e entrega eventos da sessão; sem isto, downloads grandes podem não concluir bem.
//

import UIKit

final class ClairfyAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        ModelDownloadCoordinator.shared.setBackgroundSessionEventsCompletionHandler(completionHandler)
    }
}
