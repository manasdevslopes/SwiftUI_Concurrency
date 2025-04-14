//
// PhotoPickerBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 14/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//

import PhotosUI
import SwiftUI

@MainActor
final class PhotoPickerViewModel: ObservableObject {
  @Published private(set) var selectedImage: UIImage? = nil
  @Published var imageSelection: PhotosPickerItem? = nil {
    didSet {
      setImage(from: imageSelection)
    }
  }
  
  @Published private(set) var selectedImages: [UIImage] = []
  @Published var imageSelections: [PhotosPickerItem] = [] {
    didSet {
      setImages(from: imageSelections)
    }
  }
  
  private func setImage(from selection: PhotosPickerItem?) {
    guard let selection else { return }
    
    Task {
      /*if let data = try await selection.loadTransferable(type: Data.self) {
        if let uiimage = UIImage(data: data) {
          selectedImage = uiimage
          return
        }
      }*/
      
      do {
        let data = try await selection.loadTransferable(type: Data.self)
        guard let data, let uiImage = UIImage(data: data) else {
          throw URLError(.badServerResponse)
        }
        selectedImage = uiImage
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  private func setImages(from selections: [PhotosPickerItem]) {
    Task {
      var images: [UIImage] = []
      for selection in selections {
        if let data = try await selection.loadTransferable(type: Data.self) {
          if let uiImage = UIImage(data: data) {
            images.append(uiImage)
          }
        }
      }
      selectedImages = images
    }
  }
}

struct PhotoPickerBootcamp: View {
  @StateObject private var vm = PhotoPickerViewModel()
  
  var body: some View {
    VStack(spacing: 40) {
      if let image = vm.selectedImage {
        Image(uiImage: image).resizable().scaledToFill().frame(width: 200, height: 200)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      
      PhotosPicker(selection: $vm.imageSelection, matching: .images) {
        Text("Open the Photo Picker!").foregroundStyle(.red)
      }
      
      if !vm.selectedImages.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(vm.selectedImages, id: \.self) { image in
              Image(uiImage: image)
                .resizable().scaledToFill().frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
          }
        }
      }
      
      PhotosPicker(selection: $vm.imageSelections, matching: .images) {
        Text("Select Multiple photos from the Photo Picker!").foregroundStyle(.blue)
      }
    }
  }
}

#Preview {
  PhotoPickerBootcamp()
}
