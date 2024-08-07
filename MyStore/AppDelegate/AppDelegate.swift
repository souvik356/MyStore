//
//  AppDelegate.swift
//  MyStore
//
//  Created by souvik_roy on 10/07/24.
//

import UIKit
import Appwrite
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import AVFoundation
import Photos


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    let client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("668f63b7000473d37faf")
        .setSelfSigned(true) // For self signed certificates, only use for development



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func requestCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    // Already authorized
                    break
                case .notDetermined:
                    // Not yet determined, request permission
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            print("Camera access granted")
                        } else {
                            print("Camera access denied")
                        }
                    }
                case .denied, .restricted:
                    // Denied or restricted
                    print("Camera access denied or restricted")
                @unknown default:
                    fatalError("Unexpected authorization status")
                }
            }
        
        func requestPhotoLibraryPermission() {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                // Already authorized
                break
            case .notDetermined:
                // Not yet determined, request permission
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        print("Photo library access granted")
                    } else {
                        print("Photo library access denied")
                    }
                }
            case .denied, .restricted:
                // Denied or restricted
                print("Photo library access denied or restricted")
            case .limited:
                // Limited access (introduced in iOS 14)
                print("Photo library access limited")
            @unknown default:
                fatalError("Unexpected authorization status")
            }
        }


}

