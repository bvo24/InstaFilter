//
//  ContentView.swift
//  InstaFilter
//
//  Created by Brian Vo on 5/15/24.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
   
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    
    var body: some View {
        
        VStack{
            PhotosPicker("Select your picture", selection: $pickerItems,maxSelectionCount: 3, matching: .images)
            
            ScrollView{
                ForEach(0..<selectedImages.count, id: \.self)
                {
                    i in
                    selectedImages[i]
                        .resizable()
                        .scaledToFit()
                    
                }
            }
            
        }
        .onChange(of: pickerItems){
            Task{
                selectedImages.removeAll()
                
                for item in pickerItems{
                    if let loadedImage = try await item.loadTransferable(type: Image.self){
                        selectedImages.append(loadedImage)
                    }
                }
                
            }
        }
    
            
        
    }
}

#Preview {
    ContentView()
}
