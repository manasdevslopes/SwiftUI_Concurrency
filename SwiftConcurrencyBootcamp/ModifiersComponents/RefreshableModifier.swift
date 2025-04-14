//
// RefreshableModifier.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 14/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

final class RefreshableDataService {
  func getData() async throws -> [String] {
    try? await Task.sleep(nanoseconds: 5_000_000_000)
    return ["Apple", "Orange", "Banana"].shuffled()
  }
}

final class RefreshableModifierViewModel: ObservableObject {
  let manager = RefreshableDataService()
  @Published private(set) var items: [String] = []
  
  func loadData() async {
    do {
      items = try await manager.getData()
    } catch {
      print(error.localizedDescription)
    }
  }
}

struct RefreshableModifier: View {
  @StateObject private var vm = RefreshableModifierViewModel()
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          ForEach(vm.items, id: \.self) {
            Text($0).font(.headline)
          }
        }
      }
      .navigationTitle("Refreshable")
      .refreshable {
        await vm.loadData()
      }
      .task {
        await vm.loadData()
      }
    }
  }
}

#Preview {
  RefreshableModifier()
}
