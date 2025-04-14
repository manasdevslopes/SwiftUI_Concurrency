//
// CheckedContinuation.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 14/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

class CheckedContinuationNetworkManager {
  func getData(url: URL) async throws -> Data {
    do {
      let (data, _) = try await URLSession.shared.data(from: url) // Concurrent function
      return data
    } catch {
      throw error
    }
  }
  
  func getData2(url: URL) async throws -> Data { // But we have to use async concurrent function
    return try await withCheckedThrowingContinuation { continuation in
      URLSession.shared.dataTask(with: url) { data, response, error in // This is non-concurrent function
        if let data {
          continuation.resume(returning: data)
        } else if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(throwing: URLError(.badURL))
        }
      }.resume()
    }
  }
  // One more example with completionhandler and non-concurrent function
  func getHeartImageFromDatabase(completion: @escaping (_ image: UIImage) -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      completion(UIImage(systemName: "heart.fill")!)
    }
  }
  // Convert this into Async-await concurrent function
  func getHeartImageFromDatabase() async -> UIImage {
    return await withCheckedContinuation { continuation in
      getHeartImageFromDatabase { image in
        continuation.resume(returning: image)
      }
    }
  }
}

class CheckedContinuationViewModel: ObservableObject {
  let networkManager = CheckedContinuationNetworkManager()
  @Published var image: UIImage? = nil
  @Published var image2: UIImage? = nil
  @MainActor
  func getImage() async {
    guard let url = URL(string: "https://picsum.photos/300") else { return }
    
    do {
      // let data = try await networkManager.getData(url: url)
      let data = try await networkManager.getData2(url: url)
      if let image = UIImage(data: data) {
        self.image = image
      }
    } catch { }
  }
  
  @MainActor
  func getHeartImage() async {
    self.image2 = await networkManager.getHeartImageFromDatabase()
    /*networkManager.getHeartImageFromDatabase {[weak self] image in // if the function is not converted then need to use like this , OLD WAY
      self?.image2 = image
    }*/
  }
}

// When any function or SDK is not using async-await concurrency like URLSession.shared.dataTask with completion handler, then need to use CheckedContinuation to covert that function or SDK into Async Call.
struct CheckedContinuation: View {
  @StateObject private var vm = CheckedContinuationViewModel()
  
  var body: some View {
    VStack {
      if let image = vm.image {
        Image(uiImage: image).resizable().scaledToFit().frame(width: 200, height: 200)
          .clipShape(RoundedRectangle(cornerRadius: 25))
      }
      if let image2 = vm.image2 {
        Image(uiImage: image2).resizable().scaledToFit().frame(width: 200, height: 200)
      }
    }
    .task {
      await vm.getImage()
      await vm.getHeartImage()
    }
  }
}

#Preview {
  CheckedContinuation()
}
