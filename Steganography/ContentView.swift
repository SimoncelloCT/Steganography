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
        HStack{
            TabView{
                HideImageView(images: images)
                    .tabItem {
                        Image(systemName: "square.and.arrow.down")
                        Text("Hide image")

                    }
                UnhideImageView(images: images)
                    .tabItem {
                        Image(systemName: "square.and.arrow.up")
                        Text("Unhide image")
                    }
            }
        }
    }
}


   public class Images : ObservableObject {
        @Published var firstImage : UIImage?
        @Published var secondImage : UIImage?
        @Published var unhidableImage: UIImage?
        @Published var unhiddenImage: UIImage?
        
        public func empty(){
            firstImage = nil
            secondImage = nil
        }
    }


    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView(showImagePicker: true, imageView: nil, images: Images())
        }
    }

