//
//  ImageProcessor.swift
//  Steganography
//
//  Created by Simone Scionti on 01/04/21.
//

import Foundation
import UIKit
import Combine
import CryptoSwift

public class ImageProcessor{
    private var height: Int
    private var width : Int
  
    private var originalPixels: UnsafeMutablePointer<RGBA32>!
    private var pixelsToHide: UnsafeMutablePointer<RGBA32>!
    private var bitPlanes : Int!
    
    public init(height : Int, width: Int){
        self.height = height
        self.width = width
        self.bitPlanes = 2
    }
    
    func getContext(in image: UIImage) -> CGContext? {
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        
        guard let CGImage = image.cgImage else {
                print("unable to get cgImage")
                return nil
            }
        
        context.draw(CGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context
    }

    func getImageFromContext(context: CGContext, scale: CGFloat , orientation : UIImage.Orientation) -> UIImage{
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: scale, orientation: orientation)
        return outputImage
    }
    
    //collapse 4 bytes into a single one taking only 2 msb foreach.
    func collapseToBytes(data: UnsafeMutablePointer<RGBA32>) -> Data?{
        let mask = getMaskMsb(bitPlanes: 2)
        let bytesCount = width*height*4
        let originalBytes = Data(bytesNoCopy: data, count: width*height*4, deallocator: .none).bytes
        var encryptableBytes = [UInt8]()
        //foreach byte take just the 2 msb and remove others. Concat 4 byte - 4 byte
        for i in 0..<bytesCount/4{
            var firstByte = originalBytes[i*4]
            firstByte = firstByte & mask //leave only 2 msb
            for j in 1..<4{
                var byte = originalBytes[(i*4)+j]
                byte = byte & mask //take 2 msb
                byte = byte >> (j * 2) //shift of j * 2 pos on the right
                firstByte = firstByte | byte
            }
            encryptableBytes.append(firstByte)
        }
        return Data(encryptableBytes)
    }
    
    //returns an array with 4 bytes for each crypted byte
    func decollapseToPixels(data: Data, pixels : inout UnsafeMutablePointer<RGBA32>){
        let mask = getMaskMsb(bitPlanes: 2)
        let originalBytes = data;
        let pixelsCount = Int(width * height); //less because we took 1 byte each 4.
        for i in 0..<pixelsCount{
            var bytes = [UInt8]()
            let byte = originalBytes[i];
            bytes.append(UInt8((byte & mask))) //first byte does not need changes, just take 2 msb
            for j in 1..<4{
                let newMask = mask >> (j * 2)
                let newByte = (byte & newMask) << (j * 2) //put in msb pos
                bytes.append(UInt8(newByte))
            }
            let pixel = RGBA32(red: bytes[3], green: bytes[2], blue: bytes[1], alpha: bytes[0])
            pixels[i] = pixel
        }
    }
    
    func encryptData(key: Array<UInt8>, data: Data) -> Data?{
        do{
            let aes = try AES(key: key, blockMode: CBC(iv: Array("0123456789012345".utf8)), padding: .noPadding)
            let encrypted = try aes.encrypt(data.bytes)
           
            return Data(encrypted)
        }
        catch{
            return nil
        }
    }
    func decryptData(key: Array<UInt8>, data: Data) -> Data?{
        do{
            let decrypted = try AES(key: key, blockMode: CBC(iv: Array("0123456789012345".utf8)), padding: .noPadding).decrypt(data.bytes)
            return Data(decrypted)
            
        }
        catch{
            return nil
        }
    }


    public func hideImage(originalImage: UIImage , imageToHide: UIImage, secretKey : String) -> UIImage?{
        guard let originalImageContext = getContext(in: originalImage) else{
            print("unable to get context data")
            return nil
        }
       
        guard let imageToHideContext = getContext(in: imageToHide) else{
            print("unable to get context data")
            return nil
        }
        
        guard let originalImagePixels = originalImageContext.data else {
            print("unable to get context data")
            return nil
        }
        
        guard let imageToHidePixels = imageToHideContext.data else {
            print("unable to get context data")
            return nil
        }
        
        self.originalPixels = originalImagePixels.bindMemory(to: RGBA32.self, capacity: width * height)
        self.pixelsToHide = imageToHidePixels.bindMemory(to: RGBA32.self, capacity: width * height)
        let collapsedBytes = collapseToBytes(data: pixelsToHide)
        let key = ensure128Bit(key: secretKey)
        let encryptedBytes = self.encryptData(key: Array(key.utf8), data: collapsedBytes!)!
        self.decollapseToPixels(data: encryptedBytes, pixels: &pixelsToHide)
        transformPixels(bitPlanes: bitPlanes)
        return getImageFromContext(context: originalImageContext, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }
    
    
    public func unhideImage(stegImage: UIImage, secretKey : String)-> UIImage?{
        guard let stegImageContext = getContext(in: stegImage) else{
            print("unable to get context data")
            return nil
        }
        guard let stegImagePixels = stegImageContext.data else {
            print("unable to get context data")
            return nil
        }
        self.originalPixels = stegImagePixels.bindMemory(to: RGBA32.self, capacity: width * height)
        extractHiddenImage(bitPlanes: bitPlanes)
        let collapsedBytes = collapseToBytes(data: originalPixels)
        //128 bit key
        let key = ensure128Bit(key: secretKey)
        //secret0key000000
        let dataDecr = self.decryptData(key: Array(key.utf8), data: collapsedBytes!)
        self.decollapseToPixels(data: dataDecr!, pixels: &originalPixels)
        return getImageFromContext(context: stegImageContext, scale: stegImage.scale, orientation: stegImage.imageOrientation)
    }
    
    func extractHiddenImage(bitPlanes: Int){
        let mask  = getMaskMsb(bitPlanes: bitPlanes)
        let shift = 8-bitPlanes
        for offset in 0 ..< (width * height) {
            let originalPixel = originalPixels[offset]
            let changedPixel = RGBA32(red: (originalPixel.redComponent << shift) & mask, green: (originalPixel.greenComponent << shift) & mask, blue: (originalPixel.blueComponent << shift) & mask, alpha: (originalPixel.alphaComponent << shift) & mask)
            originalPixels[offset] = changedPixel
        }
    }

    func transformPixels(bitPlanes: Int){
        let mask = getMaskLsb(bitPlanes: bitPlanes)
        for offset in 0 ..< (width * height) {
            let originalPixel = originalPixels[offset]
            let pixelToHide = pixelsToHide[offset]
            let originalNewPixel = RGBA32(red: originalPixel.redComponent & mask, green: originalPixel.greenComponent & mask, blue: originalPixel.blueComponent & mask, alpha: originalPixel.alphaComponent & mask)
            //take bp msb and shift in lsb
            let rightShift = 8-bitPlanes
            let newToHidePixel = RGBA32(red: pixelToHide.redComponent >> rightShift, green: pixelToHide.greenComponent >> rightShift, blue: pixelToHide.blueComponent >> rightShift, alpha: pixelToHide.alphaComponent >> rightShift)
            let changedPixel = RGBA32(red: originalNewPixel.redComponent | newToHidePixel.redComponent, green: originalNewPixel.greenComponent | newToHidePixel.greenComponent, blue: originalNewPixel.blueComponent | newToHidePixel.blueComponent, alpha: originalNewPixel.alphaComponent | newToHidePixel.alphaComponent)
            originalPixels[offset] = changedPixel
        }
    }
    
    private func ensure128Bit(key: String) -> String{
        var newKey = key
        if(newKey.count < 16){
            //add padding
            for _ in 0..<(16-key.count){
                newKey.append("0")
            }
        }
        return newKey
    }
    
    private func getMaskMsb(bitPlanes: Int) -> UInt8{
        var mask : UInt8 = 0
        for i in 0..<bitPlanes{
            mask += UInt8(truncating: NSDecimalNumber(decimal: (pow(2, i))))
        }
        let shift = 8-bitPlanes
        mask = mask << shift
        return mask
    }
    
    private func getMaskLsb(bitPlanes: Int) -> UInt8{
        var mask : UInt8 = 0
        for i in 0..<8-bitPlanes{
            mask += UInt8(truncating: NSDecimalNumber(decimal: (pow(2, i))))
        }
        mask = mask << bitPlanes
        return mask
    }
}

struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }

        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }

        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }

        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
    }
}



