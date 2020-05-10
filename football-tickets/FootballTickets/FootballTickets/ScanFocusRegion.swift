//
//  ScanFocusRegion.swift
//  BarcodeScanner
//
//  Created by Sameer Dandekar on 2/15/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import Foundation
import SwiftUI
 
/*
 -----------------------------------------------------------------------------
 We create a scan focus region image to guide the user during scanning.
 However, the entire screen is capable of detecting and reading the barcode.
 The user actually does not need to place the barcode within the focus region.
 -----------------------------------------------------------------------------
 */
 
// Global variable providing the scan focus region image
var scanFocusRegionImage = Image("ImageUnavailable")
 
// This function is called from AppDelegate upon app launch
public func createScanFocusRegionImage() {
   
    // Declare and initialize view width and height
    let viewWidth: CGFloat = UIScreen.main.bounds.width - 40
    let viewHeight: CGFloat = 200
   
    // Create an image view object to show the scanning focus region
    let scanningRegionView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
   
    // Create a bitmap-based graphics context as big as the scanning focus region and make it the Current Context
    UIGraphicsBeginImageContext(scanningRegionView.frame.size)
 
    // Draw the entire image in the specified rectangle, which is the entire scanning focus region view frame
    scanningRegionView.image?.draw(in: CGRect(x: 0, y: 0, width: scanningRegionView.frame.width, height: scanningRegionView.frame.height))
 
    /*
    Display a left bracket "[" and right bracket "]" and a red line in the middle
    to designate the scanning focus region.  w = viewWidth and h = viewHeight
 
    (0,h) ------- (30,h)         (w-30,h) ------- (w,h)
    |                                                 |
    |                                                 |
    |                                                 |
    |                 focus red line                  |
    |   ------------------------------------------    |
    |                                                 |
    |                                                 |
    |                                                 |
    |                                                 |
    (0,0) ------- (30,0)         (w-30,0) ------- (w,0)
    */
 
    //-------------------------------------------
    //         Draw the Left Bracket
    //-------------------------------------------
 
    // Set the line drawing starting coordinate to (30,0)
    UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: 30.0, y: 0.0))
 
    // Draw left bracket bottom line from (30,0) to (0,0)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: 0.0, y: 0.0))
 
    // Draw left bracket left line from (0,0) to (0,h)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: 0.0, y: viewHeight))
 
    // Draw left bracket top line from (0,h) to (30,h)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: 30.0, y: viewHeight))
 
    //-------------------------------------------
    //         Draw the Right Bracket
    //-------------------------------------------
 
    // Set the line drawing starting coordinate to (w-30,0)
    UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: viewWidth - 30.0, y: 0.0))
 
    // Draw right bracket bottom line from (w-30,0) to (w,0)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: viewWidth, y: 0.0))
 
    // Draw right bracket right line from (w,0) to (w,h)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
 
    // Draw right bracket top line from (w,h) to (w-30,h)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: viewWidth - 30.0, y: viewHeight))
 
    //-------------------------------------------
    //    Set Properties of the Bracket Lines
    //-------------------------------------------
 
    // Set the bracket lines with a squared-off end
    UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.butt)
 
    // Set the bracket line width to 5
    UIGraphicsGetCurrentContext()?.setLineWidth(5)
 
    // Set the bracket line color to dark gray
    UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.darkGray.cgColor)
 
    // Set the bracket line blend mode to be normal
    UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
 
    // Set the bracket line stroke path
    UIGraphicsGetCurrentContext()?.strokePath()
 
    // Set the bracket line Antialiasin off
    UIGraphicsGetCurrentContext()?.setAllowsAntialiasing(false)
 
    //-------------------------------------------
    //    Draw the Red Line as the Focus Line
    //-------------------------------------------
 
    // Set the line drawing starting coordinate to (10% of viewWidth, half of viewHeight)
    UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: viewWidth * 0.10, y: viewHeight / 2.0))
 
    // Draw the focus line to (90% of viewWidth, half of viewHeight)
    UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: viewWidth * 0.9, y: viewHeight / 2.0))
 
    // Set the properties of the red focus line
    UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.butt)
    UIGraphicsGetCurrentContext()?.setLineWidth(1)
    UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.red.cgColor)
    UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
    UIGraphicsGetCurrentContext()?.strokePath()
 
    // Set the image based on the contents of the current bitmap-based
    // graphics context to be the scanningRegionView's image
    scanningRegionView.image = UIGraphicsGetImageFromCurrentImageContext()
   
    /*
     scanningRegionView is a UIImageView. The image of a UIImageView is of type UIImage.
     Convert UIImage to SwiftUI Image view and store its unique ID into the global variable.
     */
    scanFocusRegionImage = Image(uiImage: scanningRegionView.image!)
 
    // Remove the current bitmap-based graphics context from the top of the stack
    UIGraphicsEndImageContext()
}
 
 
