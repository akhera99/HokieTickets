//
//  BarcodeScanner.swift
//  BarcodeScanner
//
//  Created by Sameer Dandekar on 2/15/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
import UIKit
import AVKit
import AudioToolbox
 
/*
------------------------------------------------------------------------------------
 SwiftUI framework does not yet directly support barcode scanning. Therefore,
 we do it by using UIKit's UIViewController class, which is wrapped by this
 BarcodeScanner struct to interface with SwiftUI.
 
 Wrapping a UIViewController requires us to create a struct that conforms to the
 UIViewControllerRepresentable protocol, which requires us to implement two methods:
 
 makeUIViewController()     Creates the initial view controller
 updateUIViewController()   Updates the view controller when SwiftUI state changes
------------------------------------------------------------------------------------
*/
struct BarcodeScanner: UIViewControllerRepresentable {
   
    typealias UIViewControllerType = ScannerViewController
   
    // Binding variable used to update the main SwiftUI view
    @Binding var code: String
//    @Binding var showAlert: Bool
   
    // Coordinator class is created to coordinate with the UIViewController.
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var scanner: BarcodeScanner
       
        init(_ parent: BarcodeScanner) {
            self.scanner = parent
        }
       
        /*
         AVCaptureMetadataOutput: A capture output for processing timed metadata produced by a capture session.
         AVMetadataObject:        The abstract superclass for objects provided by a metadata capture output.
         AVCaptureConnection:     A connection between a specific pair of capture input and capture output objects in a capture session.
         */
        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
           
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let barcodeString = readableObject.stringValue else { return }
               
                /*
                 If barcode reading is successful, the obtained barcode String value is assigned to
                 the binding variable 'code', which causes to update the main SwiftUI view.
                 */
                self.scanner.code = barcodeString
               
                /*
                 Briefly vibrate iPhone to inform the user that scanning is completed.
                 The user must turn on 'Vibrate on Ring' in 'Sounds & Haptics' in the
                 Settings app for the vibrate to work.
                 */
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
   
    // Creates a coordinator instance to coordinate with the UIViewController.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
   
    // Creates a UIViewController instance to present.
    func makeUIViewController(context: UIViewControllerRepresentableContext<BarcodeScanner>) -> BarcodeScanner.UIViewControllerType {
       
        // Create a ScannerViewController() instance and store its unique id into local variable scanner
        let scanner = ScannerViewController()
       
        // Set context.coordinator to be scanner's delegate
        scanner.delegate = context.coordinator
       
        // Return the created scanner
        return scanner
    }
   
    // Updates the presented UIViewController (and coordinator) to the latest configuration.
    func updateUIViewController(_ uiViewController: BarcodeScanner.UIViewControllerType,
                                context: UIViewControllerRepresentableContext<BarcodeScanner>) {
        /*
         No update is necessary since we use the @State variable 'barcode' to update the view.
         */
    }
}
 
 
 
