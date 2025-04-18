//
// GlobalActorBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 18/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

// To make getData() function isolated to this actor MyNewDataManager. We don't access this MyNewDataManager directly,
// We use MyFirstGlobalActor to access MyNewDataManager
// here, is the steps:
// Can use struct or final class
@globalActor struct MyFirstGlobalActor {
  static var shared = MyNewDataManager()
}

actor MyNewDataManager {
  func getDataFromDatabase() -> [String] {
    ["One", "Two", "Three", "Four", "Five"]
  }
}

@MainActor class GlobalActorViewModel: ObservableObject {
  // If we put @MainActor infront of the published properties, which is affecting the UI, then instantly Xcode will complain this - self.dataArray = data should run on MainActor. Or put @MainActor infront of class, if there many published property with UI updation ie @MainActor.
  /*@MainActor*/ @Published var dataArray: [String] = []
  /*@MainActor*/ @Published var dataArray1: [String] = []
  /*@MainActor*/ @Published var dataArray2: [String] = []
  /*@MainActor*/ @Published var dataArray3: [String] = []
  /*@MainActor*/ @Published var dataArray4: [String] = []
  let manager = MyFirstGlobalActor.shared
  
  // Now this function also becomes isolated to actor
  @MyFirstGlobalActor func getData() async {
    Task {
      let data = await manager.getDataFromDatabase()
      await MainActor.run {
        self.dataArray = data
      }
    }
  }
}

struct GlobalActorBootcamp: View {
  @StateObject private var vm = GlobalActorViewModel()
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(vm.dataArray, id: \.self) { item in
          Text(item).font(.headline)
        }
      }
    }
    .task {
      await vm.getData()
    }
  }
}

#Preview {
  GlobalActorBootcamp()
}
