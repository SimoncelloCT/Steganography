//
//  UnhideImageView.swift
//  Steganography
//
//  Created by Simone Scionti on 19/04/21.
//

import SwiftUI

struct UnhideImageView: View {
    @State var showImagePicker: Bool = false
    @StateObject var images: Images
    var body: some View {
        VStack{
            Button(action: {
                 images.empty()
                 self.showImagePicker.toggle()
            }) {
                Text("Select image")
            }
             Button(action: {
                 let processor = ImageProcessor(height: 400, width: 400)
                 images.processedImage = processor.unhideImage(stegImage: images.processedImage!, secretKey: "ciao")
             }) {
                 Text("Unhide image")
             }.disabled(images.processedImage == nil)
            Image(uiImage: images.processedImage ?? UIImage())
                .resizable().frame(width: 400, height: 400)
         }
     
         .sheet(isPresented: $showImagePicker) {
             ImagePicker(sourceType: .photoLibrary) { image in
                images.processedImage = image
             }
         }
    }
}

struct UnhideImageView_Previews: PreviewProvider {
    static var previews: some View {
        UnhideImageView(images: Images())
    }
}
