//
//  ContentView.swift
//  Steganography
//
//  Created by Simone Scionti on 01/04/21.
//

import SwiftUI

struct ContentView: View {
    @State var showImagePicker: Bool = false
    @State var imageView: Image? = nil
    @StateObject var images: Images
    var body: some View {
                    VStack {
                        HStack{
                            Button(action: {
                                 images.empty()
                                 self.showImagePicker.toggle()
                            }) {
                                Text("Select an original image")
                            }
                             Button(action: {
                                 self.showImagePicker.toggle()
                             }) {
                                 Text("Selectan image to hide")
                             }
                             Button(action: {
                                 let processor = ImageProcessor(height: 400, width: 400)
                                 images.processedImage = processor.hideImage(originalImage: images.firstImage!, imageToHide: images.secondImage!, secretKey: "ciao")!
                                 imageView = Image(uiImage: images.processedImage!)
                             }) {
                                 Text("Hide image")
                             }
                             
     //                        Button(action: {
     //                            self.showImagePicker.toggle()
     //                        }) {
     //                            Text("Select image to unhide")
     //                        }
                             Button(action: {
                                 let processor = ImageProcessor(height: 400, width: 400)
                                 images.processedImage = processor.unhideImage(stegImage: images.processedImage!, secretKey: "ciao")
                                 imageView = Image(uiImage: images.processedImage!)
                             }) {
                                 Text("Unhide image")
                             }
     //                        Button(action: {
     //                            UIImageWriteToSavedPhotosAlbum(ImageSelection.getUniqueIstance().processedImage!, nil, nil, nil)
     //                        }) {
     //                            Text("Save processed image")
     //                        }
                        }

                        
                        imageView?.resizable().frame(width: 400, height: 400)
                    }
                
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(sourceType: .photoLibrary) { image in
                            if let _ = images.firstImage{
                                images.secondImage = image
                            }
                            else{
                                images.firstImage = image
                                imageView = Image(uiImage: image)
                            }
                        }
                    }
            }
}


class Images : ObservableObject {
    @Published var firstImage : UIImage?
    @Published var secondImage : UIImage?
    @Published var processedImage: UIImage?
    
    public func empty(){
        firstImage = nil
        secondImage = nil
    }
}



struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    private var presentationMode

    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    final class Coordinator: NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {

        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void

        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showImagePicker: true, imageView: nil, images: Images())
    }
}
