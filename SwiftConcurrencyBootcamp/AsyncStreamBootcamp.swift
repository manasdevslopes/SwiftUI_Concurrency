//
// AsyncStreamBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 19/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
// Replacement for COMBINE Framework - AsyncStream.
    

import SwiftUI

class AsyncStreamDataManager {
  func getFakeData(newValue: @escaping (_ value: Int) -> (), onFinish: @escaping (_ error: Error?) -> ()) {
    let items: [Int] = Array(1...10)
    
    for item in items {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)) {
        newValue(item)
        print("NEW_DATA: \(item)")
        if item == items.last {
          onFinish(nil)
        }
      }
    }
  }
  
  func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
    AsyncThrowingStream { [weak self] continuation in
      self?.getFakeData { value in
        continuation.yield(value)
      } onFinish: { error in
        continuation.finish(throwing: error)
      }
    }
    
//    AsyncStream(Int.self) { [weak self] continuation in // Even we can remove this - (Int.self), code will understand
//      self?.getFakeData { value in
//        continuation.yield(value)
//      } onFinish: {
//        continuation.finish()
//      }
//    }
  }
}

@MainActor
final class AsyncStreamViewModel: ObservableObject {
  let manager = AsyncStreamDataManager()
  @Published private(set) var currentNumber: Int = 0
  
  func onViewAppear() {
//    manager.getFakeData {[weak self] value in
//      self?.currentNumber = value
//    }
    
    let task = Task {
      do {
        for try await value in manager.getAsyncStream() { // .dropFirst(2) {
          self.currentNumber = value
        }
      } catch {
        print(error)
      }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      task.cancel()
      print("TASK Cancelled")
    }
  }
}

struct AsyncStreamBootcamp: View {
  @StateObject private var vm = AsyncStreamViewModel()
  
  var body: some View {
    Text("\(vm.currentNumber)")
      .onAppear {
        vm.onViewAppear()
      }
  }
}

#Preview {
    AsyncStreamBootcamp()
}
