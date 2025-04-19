//
// ObservableMacroBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 19/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

actor TitleDatabase {
  func getNewTitle() -> String {
    "Some New Title!"
  }
}

@MainActor
@Observable class ObservableMacroViewModel {
  @ObservationIgnored let db = TitleDatabase()
  /* @MainActor */ var title: String = "Starting Title"
  
  /* @MainActor */
  func updateTitle() async {
    title = await db.getNewTitle()
    print(Thread.current)
    
    /*
     let title = await db.getNewTitle()
     
     await MainActor.run {
     self.title = title
     print(Thread.current)
     }
     */
  }
}

struct ObservableMacroBootcamp: View {
  @State private var vm = ObservableMacroViewModel()
  
  var body: some View {
    Text(vm.title)
      .task {
        await vm.updateTitle()
      }
  }
}

#Preview {
  ObservableMacroBootcamp()
}
