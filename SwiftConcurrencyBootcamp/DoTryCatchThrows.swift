//
// DoTryCatchThrows.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 10/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

class DoTryCatchThrowsDataManager {
  let isActive: Bool = true
  func getTitle() -> (title: String?, error: Error?) {
    isActive ? ("New Title.", nil) : (nil, URLError(.badURL))
  }
  
  func getTitle2() -> Result<String, Error> {
    isActive ? .success("New Title") : .failure(URLError(.badURL))
  }
  
  func getTitle3() throws -> String {
//    if isActive {
//      "New Title"
//    } else {
      throw URLError(.badURL)
//    }
  }
  
  func getTitle4() throws -> String {
    if isActive {
      "Final Title"
    } else {
      throw URLError(.badURL)
    }
  }
}

class DoTryCatchThrowsViewModel: ObservableObject {
  let manager = DoTryCatchThrowsDataManager()
  @Published var text: String = "Starting Text."
  
  func fetchTitle() {
    /*
     let returnedValue = manager.getTitle()
     if let title = returnedValue.title {
     text = title
     } else if let error = returnedValue.error {
     text = error.localizedDescription
     }
     */
    
    /*
     let returnedValue = manager.getTitle2()
     switch returnedValue {
     case .success(let newTitle):
     text = newTitle
     case .failure(let error):
     text = error.localizedDescription
     }
     */
    
    // let secondInitialText = try! manager.getTitle3()
    // self.text = secondInitialText
    
    let secondInitialText = try? manager.getTitle3()
    if let secondInitialText {
      self.text = secondInitialText
    }
    
    do {
      let secondText = try? manager.getTitle3()
      // self.text = secondText ?? "Default Text"
      if let secondText {
        self.text = secondText
      }
      // If there are multiple try statements, and any of the try fails, then immediately it will go to catch
      
      let finalTitle = try manager.getTitle4()
      self.text = finalTitle
    } catch {
      self.text = error.localizedDescription
    }
  }
}

struct DoTryCatchThrows: View {
  @StateObject private var vm = DoTryCatchThrowsViewModel()
  
  var body: some View {
    Text(vm.text).frame(width: 300, height: 300).background(.blue)
      .onTapGesture {
        vm.fetchTitle()
      }
  }
}

#Preview {
  DoTryCatchThrows()
}
