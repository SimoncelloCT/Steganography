//
//  SteganographyApp.swift
//  Steganography
//
//  Created by Simone Scionti on 01/04/21.
//

import SwiftUI

@main
struct SteganographyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(images: Images())
        }
    }
}
