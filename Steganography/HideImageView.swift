//
//  HideImageView.swift
//  Steganography
//
//  Created by Simone Scionti on 19/04/21.
//

import SwiftUI

struct HideImageView: View {
    @State var showImagePicker: Bool = false
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
            HStack {
                Image(systemName: "square.and.arrow.up")
                .font(.subheadline)
                Text("Select original image")
                .fontWeight(.semibold)
                .font(.subheadline)
            }
            .frame(width: 320, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .accentColor(.green)
            .background(Color(UIColor.systemGreen.withAlphaComponent(0.6)))
            .cornerRadius(15)
           }
           .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                self.showImagePicker.toggle()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    .font(.subheadline)
                    Text("Select image to hide")
                    .fontWeight(.semibold)
                    .font(.subheadline)
                }
                .frame(width: 320, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .accentColor(.green)
                .background(Color(UIColor.systemGreen.withAlphaComponent(0.6)))
                .cornerRadius(15)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            Button(action: {
                let processor = ImageProcessor(height: 400, width: 400)
                images.processedImage = processor.hideImage(originalImage: images.firstImage!, imageToHide: images.secondImage!, secretKey: encryptKeyString)!
                progressLabel = "Image hidden!"
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    .font(.subheadline)
                    Text("Hide image")
                    .fontWeight(.semibold)
                    .font(.subheadline)
                }
                .frame(width: 320, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .accentColor(.green)
                .background(Color(UIColor.systemGreen.withAlphaComponent(0.6)))
                .cornerRadius(15)
            }
            .disabled(images.firstImage == nil || images.secondImage == nil || encryptKeyString == "")
            .buttonStyle(PlainButtonStyle())
        
            TextField("Enter encrypt key", text: $encryptKeyString)
                .frame(width: 320, height: 40, alignment: .center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack{
                Image(uiImage: images.firstImage ?? UIImage())
                    .resizable().frame(width: 160, height: 160)
                    .cornerRadius(3.0)
                    .clipped()
                Image(uiImage: images.secondImage ?? UIImage())
                    .resizable().frame(width: 160, height: 160)
                    .cornerRadius(3.0)
                    .clipped()
                    
            }
            .padding()
            
            Button(action: {
                if let image = images.processedImage{
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    progressLabel = "Image saved!"
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    .font(.subheadline)
                    Text("Save processed image")
                    .fontWeight(.semibold)
                    .font(.subheadline)
                }
                .frame(width: 320, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .accentColor(.green)
                .background(Color(UIColor.systemGreen.withAlphaComponent(0.6)))
                .cornerRadius(15)
                
            }
            .disabled(images.processedImage == nil)
            .buttonStyle(PlainButtonStyle())
            
            Text(progressLabel)
                .padding()
                .accentColor(.secondary)
            
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

struct GradientBackgroundStyle: ButtonStyle {
 
    var color: Color
    
    init(color : Color) {
        self.color = color
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.none)
            .background(LinearGradient(gradient: Gradient(colors: [Color.gray, color]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15)
            .padding(.horizontal, 20)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct HideImageView_Previews: PreviewProvider {
        static var previews: some View {
        HideImageView(images: Images())
    }
}

