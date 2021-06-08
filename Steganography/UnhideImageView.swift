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
    @State var decryptKeyString = ""
    var body: some View {
        VStack{
//            Button(action: {
//                 images.empty()
//                 self.showImagePicker.toggle()
//            }) {
//                HStack {
//                    Image(systemName: "square.and.arrow.up")
//                    .font(.subheadline)
//                    Text("Select image")
//                    .fontWeight(.semibold)
//                    .font(.subheadline)
//                }
//                .frame(width: 320, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                .accentColor(.green)
//                .background(Color(UIColor.systemGreen.withAlphaComponent(0.6)))
//                .cornerRadius(15)
//            }
//            .buttonStyle(PlainButtonStyle())
            
             Button(action: {
                 let processor = ImageProcessor(height: 400, width: 400)
                 images.unhiddenImage = processor.unhideImage(stegImage: images.unhidableImage!, secretKey: decryptKeyString)
             }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    .font(.subheadline)
                    Text("Unhide image")
                    .fontWeight(.semibold)
                    .font(.subheadline)
                }
                .frame(width: 320, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .accentColor(.green)
                .background(Color(UIColor.systemGreen.withAlphaComponent(0.6)))
                .cornerRadius(15)
             }
             .buttonStyle(PlainButtonStyle())
             .disabled(images.unhidableImage == nil || decryptKeyString == "")
             .padding()
            
            TextField("Enter decrypt key", text: $decryptKeyString)
                .frame(width: 320, height: 40, alignment: .center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
            
            Image(uiImage: (images.unhiddenImage ?? images.unhidableImage) ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .cornerRadius(3.0)
                .clipped()
            
         }
     
//         .sheet(isPresented: $showImagePicker) {
//             ImagePicker(sourceType: .photoLibrary) { image in
//                images.processedImage = image
//             }
//         }
    }
}

struct UnhideImageView_Previews: PreviewProvider {
    static var previews: some View {
        UnhideImageView(images: Images())
    }
}
