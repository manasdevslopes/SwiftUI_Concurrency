//
// AsyncPublisherBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 19/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//

import Combine
import SwiftUI

actor AsyncPublisherDataManager {
  @Published var myData: [String] = []
  
  func addData() async {
    myData.append("Apple")
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    myData.append("Banana")
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    myData.append("Orange")
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    myData.append("Watermelon")
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    myData.append("Grapes")
  }
}

// @MainActor
class AsyncPublisherViewModel: ObservableObject {
  let manager = AsyncPublisherDataManager()
  @MainActor @Published var dataArray: [String] = []
  var cancellables = Set<AnyCancellable>()
  
  init() {
    addSubscribers()
  }
  
  private func addSubscribers() {
    /* If want to add multiple Subscribers, then always add multiple Task with for-loop as below */
    Task {
      for await value in await manager.$myData.values {
        await MainActor.run {
          self.dataArray = value
        }
      }
    }
//    Task {
//      for await value in manager.$myData.values {
//        await MainActor.run {
//          self.dataArray = value
//        }
//      }
//    }
//    manager.$myData
//      .receive(on: DispatchQueue.main, options: nil)
//      .sink { dataArray in
//        self.dataArray = dataArray
//      }
//      .store(in: &cancellables)
  }
  
  func start() async {
    await manager.addData()
  }
}

struct AsyncPublisherBootcamp: View {
  @StateObject private var vm = AsyncPublisherViewModel()
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(vm.dataArray, id: \.self) {
          Text($0).font(.headline)
        }
      }
    }
    .task {
      await vm.start()
    }
  }
}

#Preview {
  AsyncPublisherBootcamp()
}
