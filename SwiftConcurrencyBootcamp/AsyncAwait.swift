//
// AsyncAwait.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 13/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
  @Published var dataArray: [String] = []
  
  func addTitle1() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.dataArray.append("Title1 : \(Thread.current)")
    }
  }
  
  func addTitle2() {
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      let title2 = "Title2 : \(Thread.current)"
      DispatchQueue.main.async {
        self.dataArray.append(title2)
        
        let title3 = "Title3 : \(Thread.current)"
        self.dataArray.append(title3)
      }
    }
  }
  
  func addAuthor1() async {
    let author1 = "Author1 : \(Thread.current)"
    await MainActor.run {
      self.dataArray.append(author1)
    }
  
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    
    let author2 = "Author2 : \(Thread.current)"
    await MainActor.run {
      self.dataArray.append(author2)
      
      let author3 = "Author3 : \(Thread.current)"
      self.dataArray.append(author3)
    }
    
    await addSomething()
  }
  
  func addSomething() async {
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    let something1 = "Something1 : \(Thread.current)"
    await MainActor.run {
      self.dataArray.append(something1)
      
      let something2 = "Something2 : \(Thread.current)"
      self.dataArray.append(something2)
    }
    
  }
}

struct AsyncAwait: View {
  @StateObject private var vm = AsyncAwaitViewModel()
  
  var body: some View {
    List {
      ForEach(vm.dataArray, id: \.self) { data in
        Text(data)
      }
    }
    .onAppear {
      vm.addTitle1()
      vm.addTitle2()
      
      Task {
        await vm.addAuthor1()
        
        let finalText = "FinalText : \(Thread.current)"
        vm.dataArray.append(finalText)
      }
    }
  }
}

#Preview {
  AsyncAwait()
}
