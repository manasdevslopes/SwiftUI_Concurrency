//
// AsyncLet.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 14/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

// Letting us perform multiple methods at the same time, & then wait for the result of all those methods together
struct AsyncLet: View {
  @State private var images: [UIImage] = []
  @State private var heading: String = "New Title"
  @State private var fetchedImageTask: Task<(), Never>? = nil
  let columns = [GridItem(.flexible()), GridItem(.flexible())]
  let url = URL(string: "https://picsum.photos/300")!
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns) {
          ForEach(images, id: \.self) { image in
            Image(uiImage: image).resizable().scaledToFit().frame(height: 150)
              .clipShape(RoundedRectangle(cornerRadius: 25))
          }
        }
      }
      .navigationTitle(heading)
      .onDisappear {
        fetchedImageTask?.cancel()
      }
      .onAppear {
        /* Cancel Task example */
        fetchedImageTask = Task {
          do {
            async let fetchImage1 = fetchImage()
            async let fetchImage2 = fetchImage()
            async let fetchImage3 = fetchImage()
            async let fetchImage4 = fetchImage()
            async let fetchTitle1 = fetchTitle()
            
            // let (image1, image2, image3, image4) = await (try? fetchImage1, try? fetchImage2, try? fetchImage3, try? fetchImage4)
            let (image1, image2, image3, image4, title1) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4, fetchTitle1)
            self.images.append(contentsOf: [image1, image2, image3, image4])
            self.heading = title1
            
            /*
//            let image1 = try await fetchImage()
//            self.images.append(image1)
//            
//            let image2 = try await fetchImage()
//            self.images.append(image2)
//            
//            let image3 = try await fetchImage()
//            self.images.append(image3)
//            
//            let image4 = try await fetchImage()
//            self.images.append(image4)
             */
          } catch {
            
          }
        }
      }
    }
  }
  
  private func fetchImage() async throws -> UIImage {
    do {
      let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
      if let image = UIImage(data: data) {
        return image
      } else {
        throw URLError(.badURL)
      }
    } catch {
      throw error
    }
  }
  
  private func fetchTitle() async -> String {
    "Async Let 🤙"
  }
}

#Preview {
  AsyncLet()
}
