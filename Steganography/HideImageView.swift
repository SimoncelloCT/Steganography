//
//  HideImageView.swift
//  Steganography
//
//  Created by Simone Scionti on 19/04/21.
//

import SwiftUI

struct HideImageView: View {
    @State var showImagePicker: Bool = false
    @State var showDialog: Bool = false
    @State var encryptKeyString : String = ""
    @StateObject var images: Images
    @State var progressLabel : String = ""
    var body: some View {
        VStack {
           Button(action: {
                images.empty()
                self.showImagePicker.toggle()
                progressLabel = ""
           }) {
               Text("Select original image")
              
           }
            Button(action: {
                self.showImagePicker.toggle()
            }) {
                Text("Select image to hide")
            }
            Button(action: {
                showDialog = true
            }) {
                Text("Hide image")
            }.disabled(images.firstImage == nil || images.secondImage == nil)
            
            Button(action: {
                if let image = images.processedImage{
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    progressLabel = "Image saved!"
                }
            }) {
                Text("Save processed image")
            }.disabled(images.processedImage == nil)
            
            HStack{
                Image(uiImage: images.firstImage ?? UIImage())
                    .resizable().frame(width: 200, height: 200)
                Image(uiImage: images.secondImage ?? UIImage())
                    .resizable().frame(width: 200, height: 200)
            }
            .padding()
            
            if showDialog {
                ZStack{
                    Text("Enter an encrypt key")
                    VStack{
                        TextField("Enter encrypt key", text: $encryptKeyString)
                        Spacer()
                        Button(action: {
                            self.showDialog = false
                            let processor = ImageProcessor(height: 400, width: 400)
                            images.processedImage = processor.hideImage(originalImage: images.firstImage!, imageToHide: images.secondImage!, secretKey: encryptKeyString)!
                            progressLabel = "Image hidden!"
                        }, label: {
                            Text("Encrypt")
                        })
                        .disabled(encryptKeyString == "")
                    }
                    .padding()
                }.frame(width: 300, height: 200)
                .cornerRadius(20).shadow(radius: 20)
            }
            
            Text(progressLabel)
                
        }
    
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                if let _ = images.firstImage{
                    images.secondImage = image
                }
                else{
                    images.firstImage = image
                }
            }
        }
    }
}

struct HideImageView_Previews: PreviewProvider {
        static var previews: some View {
        HideImageView(images: Images())
    }
}

