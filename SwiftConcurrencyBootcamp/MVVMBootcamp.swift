//
// MVVMBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 18/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

final class MyManagerClass {
  func getData() async throws -> String {
    "Some Data!"
  }
}

actor MyManagerActor {
  func getData() async throws -> String {
    "Some Data!"
  }
}

@MainActor
final class MVVMBootcampViewModel: ObservableObject {
  let managerClass = MyManagerClass()
  let managerActor = MyManagerActor()
  
  // @MainActor
  @Published private(set) var myData: String = "Starting Text!"
  
  private var tasks: [Task<(), Never>] = []
  
  func cancelTasks() {
    tasks.forEach({ $0.cancel() })
    tasks = []
  }
  
  // @MainActor
  func onCallToActionButtonPressed() {
    let task = Task { // @MainActor in
      do {
        // myData = try await managerClass.getData()
        myData = try await managerActor.getData()
      } catch {
        print(error.localizedDescription)
      }
    }
    tasks.append(task)
  }
}

struct MVVMBootcamp: View {
  @StateObject private var vm = MVVMBootcampViewModel()
  
  var body: some View {
    VStack {
      Button(vm.myData) {
        vm.onCallToActionButtonPressed()
      }
      Button("Click Me") {
        vm.onCallToActionButtonPressed()
      }
    }
    .onDisappear {
      vm.cancelTasks()
    }
  }
}

#Preview {
  MVVMBootcamp()
}
