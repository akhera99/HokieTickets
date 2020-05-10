//
//  FlashlightButton.swift
//  BarcodeScanner
//
//  Created by Sameer Dandekar on 2/15/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
import AVFoundation
 
struct FlashlightButton: View {
 
    @Binding var lightOn: Bool
   
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                self.toggleLight()
            }
        }) {
            Image(systemName: (lightOn ? "bolt.fill" : "bolt"))
                .imageScale(.medium)
                .font(Font.title.weight(.regular))
                .foregroundColor(self.lightOn ? .yellow: .blue)
                .scaleEffect(self.lightOn ? 1.2 : 1.0)
                .rotationEffect(.degrees(self.lightOn ? 360: 0))
        }
    }
   
    func toggleLight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        self.lightOn.toggle()
       
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = (self.lightOn) ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Unable to Activate Flashlight!")
            }
        } else {
            print("Flashlight is Unavailable!")
        }
    }
}
 
 
