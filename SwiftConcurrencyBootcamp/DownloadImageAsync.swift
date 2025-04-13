//
// DownloadImageAsync.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 10/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

class DownloadImageAsyncImageLoader {
  
  let url = URL(string: "https://picsum.photos/200")!
  
  func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
    guard
      let data = data,
      let image = UIImage(data: data),
      let response = response as? HTTPURLResponse,
      response.statusCode >= 200 && response.statusCode < 300 else {
      return nil
    }
    return image
  }
  
  func downloadingWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
    URLSession.shared.dataTask(with: url) {[weak self] data, response, error in
      let image = self?.handleResponse(data: data, response: response)
      completionHandler(image, error)
    }
    .resume()
  }
  
  func downloadWithAsync() async throws -> UIImage? {
    do {
      let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
      return handleResponse(data: data, response: response)
    } catch {
      throw error
    }
  }
}

class DownloadImageAsyncViewModel: ObservableObject {
  let loader = DownloadImageAsyncImageLoader()
  @Published var image: UIImage? = nil
  
  func fetchImage() async {
    /*
    loader.downloadingWithEscaping {[weak self] image, error in
      DispatchQueue.main.async {
        self?.image = image
      }
    }
    */
    
    let image = try? await loader.downloadWithAsync()
    await MainActor.run {
      self.image = image
    }
  }
}
struct DownloadImageAsync: View {
  @StateObject private var vm = DownloadImageAsyncViewModel()
  
    var body: some View {
      ZStack {
        if let image = vm.image {
          Image(uiImage: image).resizable().scaledToFit().frame(width: 250, height: 250)
        }
      }
      .onAppear {
        Task {
          await vm.fetchImage()
        }
      }
    }
}

#Preview {
    DownloadImageAsync()
}
