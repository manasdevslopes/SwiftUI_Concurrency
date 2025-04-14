//
// TaskGroup.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 14/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

class TaskGroupDataManager {
  let url = "https://picsum.photos/300"
  let urlStrings = [
    "https://picsum.photos/300",
    "https://picsum.photos/300",
    "https://picsum.photos/300",
    "https://picsum.photos/300",
    "https://picsum.photos/300"
  ]
  
  func fetchImagesWithAsyncLet() async throws -> [UIImage] {
    async let fetchImage1 = fetchImage(urlString: url)
    async let fetchImage2 = fetchImage(urlString: url)
    async let fetchImage3 = fetchImage(urlString: url)
    async let fetchImage4 = fetchImage(urlString: url)
    
    let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
    return [image1, image2, image3, image4]
  }
  
  func fetchImagesWithTaskGroup() async throws -> [UIImage] { // If throws then use withThrowingTaskGroup ], otherwise use withTaskGroup
    return try await withThrowingTaskGroup(of: UIImage?.self) { group in
      var images: [UIImage] = []
      images.reserveCapacity(urlStrings.count)
      
      for urlString in urlStrings {
        // if any image load group fails then every group will fail & throw error. So to avoid this put Optional try?
        // After addTask we can priority also
        // group.addTask(priority: .medium, operation: { })
        group.addTask {
          try? await self.fetchImage(urlString: urlString)
        }
      }
      /*
      group.addTask {
        try await self.fetchImage(urlString: self.url)
      }
      group.addTask {
        try await self.fetchImage(urlString: self.url)
      }
      group.addTask {
        try await self.fetchImage(urlString: self.url)
      }
      group.addTask {
        try await self.fetchImage(urlString: self.url)
      }
      */
      
      for try await image in group {
        if let image {
          images.append(image)
        }
      }
      
      return images
    }
  }
  
  private func fetchImage(urlString: String) async throws -> UIImage {
    guard let url = URL(string: urlString) else { throw URLError(.badURL) }
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let image = UIImage(data: data) {
        return image
      } else {
        throw URLError(.badURL)
      }
    } catch {
      throw error
    }
  }
}

class TaskGroupViewModel: ObservableObject {
  @Published var images: [UIImage] = []
  let manager = TaskGroupDataManager()
  
  @MainActor
  func getImages() async {
    /*if let images = try? await manager.fetchImagesWithAsyncLet() {
      self.images.append(contentsOf: images)
    }*/
    if let images = try? await manager.fetchImagesWithTaskGroup() {
      self.images.append(contentsOf: images)
    }
  }
}
// If want to run many asynchronous task, then use TaskGroup
struct TaskGroup: View {
  @StateObject private var vm = TaskGroupViewModel()
  
  let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
      NavigationStack {
        ScrollView {
          LazyVGrid(columns: columns) {
            ForEach(vm.images, id: \.self) { image in
              Image(uiImage: image).resizable().scaledToFit().frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
          }
        }
        .navigationTitle("TaskGroup 🤙")
        .task {
          await vm.getImages()
        }
      }
    }
}

#Preview {
    TaskGroup()
}
