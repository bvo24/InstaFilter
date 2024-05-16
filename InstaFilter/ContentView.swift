//
//  ContentView.swift
//  InstaFilter
//
//  Created by Brian Vo on 5/15/24.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var processedImage : Image?
    @State private var filterIntesntity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var selectedItem : PhotosPickerItem?
    
    @State private var currentFilter : CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilters = false
    
    @State private var radiusButton = false
    @State private var scaleButton = false
    @State private var intensityButton = false
    @State private var filterBool = false
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                
                //Image
                PhotosPicker(selection: $selectedItem){
                    if let processedImage{
                        processedImage
                            .resizable()
                            .scaledToFit()
                    }else{
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                HStack{
                    Text("Intensity")
                    Slider(value: $filterIntesntity)
                        .onChange(of: filterIntesntity, applyProcessing)
                        .disabled(!intensityButton)
                }
                HStack{
                    Text("Radius")
                    Slider(value: $filterRadius)
                        .onChange(of: filterRadius, applyProcessing)
                        .disabled(!radiusButton)
                }
                HStack{
                    Text("Scale")
                    Slider(value: $filterScale)
                        .onChange(of: filterScale, applyProcessing)
                        .disabled(!scaleButton)
                }
                
                HStack{
                    Button("Change filter", action: changeFilter)
                        .disabled(!filterBool)
                    //Change gilter
                    
                    Spacer()
                    
                    if let processedImage{
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                    
                    
                }
                
                
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters){
                
                Button("Cryallize"){
                    setFiler(CIFilter.crystallize())
                }
                Button("Edges"){
                    setFiler(CIFilter.edges())
                }
                Button("Gaussian Blur"){
                    setFiler(CIFilter.gaussianBlur())
                }
                Button("Pixellate"){
                    setFiler(CIFilter.pixellate())
                }
                Button("Sepiatone"){
                    setFiler(CIFilter.sepiaTone())
                }
                Button("Unsharp mask"){
                    setFiler(CIFilter.unsharpMask())
                }
                Button("Vignette"){
                    setFiler(CIFilter.vignette())
                }
                Button("Bloom"){
                    setFiler(CIFilter.bloom())
                }
                Button("Cancel", role: .cancel){ }
                
            }
            
            
            
        }
    }
    
    func changeFilter(){
        intensityButton = false
        scaleButton = false
        radiusButton = false
        showingFilters = true
        
    }
    
    func loadImage(){
        Task{
            
            filterBool = true
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else {return}
            
            guard let inputImage = UIImage(data : imageData) else {return}
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
            
            
        }
    }
    
    func applyProcessing(){
        
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey){
            intensityButton = true
            currentFilter.setValue(filterIntesntity*20, forKey: kCIInputIntensityKey)
            
        }
        if inputKeys.contains(kCIInputRadiusKey){
            radiusButton = true
            currentFilter.setValue(filterRadius*200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            scaleButton = true
            currentFilter.setValue(filterScale*100, forKey: kCIInputScaleKey)
        }
        
        
        
        guard let outputImage = currentFilter.outputImage else {return}
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else{return}
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
        
        
        
    }
    @MainActor func setFiler(_ filter: CIFilter){
        currentFilter = filter
        loadImage()
        filterCount += 1
        if filterCount >= 20{
            requestReview()
        }
    }
    
}

#Preview {
    ContentView()
}
