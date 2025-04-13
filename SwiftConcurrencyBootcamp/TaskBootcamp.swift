//
// TaskBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 13/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
  @Published var image: UIImage? = nil
  @Published var image2: UIImage? = nil

  func fetchImage() async {
    try? await Task.sleep(nanoseconds: 5_000_000_000)
    
    /*
    for x in array {
      // work
      await Task.checkCancellation()
    }
    */
    
    do {
      guard let url = URL(string: "https://picsum.photos/1000") else { return }
      let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
      await MainActor.run {
        self.image = UIImage(data: data)
        print("Image Returned Successfully")
      }
    } catch {
      print("Error fetching image: \(error.localizedDescription)")
    }
  }
  
  func fetchImage2() async {
    do {
      guard let url = URL(string: "https://picsum.photos/1000") else { return }
      let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
      await MainActor.run {
        self.image2 = UIImage(data: data)
      }
    } catch {
      print("Error fetching image: \(error)")
    }
  }
}


struct TaskBootcampHomeView: View {
  var body: some View {
    NavigationStack {
      ZStack {
        NavigationLink("CLICK ME!", destination: TaskBootcamp())
      }
    }
  }
}

struct TaskBootcamp: View {
  @StateObject private var vm = TaskBootcampViewModel()
  @State private var fetchImageTask: Task<(), Never>? = nil
  
  var body: some View {
    VStack(spacing: 40) {
      if let image = vm.image {
        Image(uiImage: image).resizable().scaledToFit().frame(width: 250, height: 250)
      }
      if let image2 = vm.image2 {
        Image(uiImage: image2).resizable().scaledToFit().frame(width: 250, height: 250)
      }
    }
//    .onAppear {
//      Task {
//        await vm.fetchImage()
//        await vm.fetchImage2()
//      }
//      Task {
//        print(Thread.current)
//        print("\(Task.currentPriority)")
//        await vm.fetchImage()
//      }
//      Task {
//        print(Thread.current)
//        print("\(Task.currentPriority)")
//        await vm.fetchImage2()
//      }
      
      /*
      Task(priority: .high) {
        // try? await Task.sleep(nanoseconds: 2_000_000_000)
        /* Instead of using sleep, we can use yield with same functionality. Meaning other task will complete first then this one. */
        await Task.yield()
        print("HIGH : \(Thread.current) : \(Task.currentPriority)")
      }
      Task(priority: .userInitiated) {
        print("USER-INITIATED : \(Thread.current) : \(Task.currentPriority)")
      }
      Task(priority: .medium) {
        print("MEDIUM : \(Thread.current) : \(Task.currentPriority)")
      }
      Task(priority: .low) {
        print("LOW : \(Thread.current) : \(Task.currentPriority)")
      }
      Task(priority: .utility) {
        print("UTILITY : \(Thread.current) : \(Task.currentPriority)")
      }
      Task(priority: .background) {
        print("BACKGROUND : \(Thread.current) : \(Task.currentPriority)")
      }
      */
      
      /* Both Tasks below will points to the same priority, in this case High / userInitiated */
      /*Task(priority: .userInitiated) {
        print("USER-INITIATED : \(Thread.current) : \(Task.currentPriority)")
        Task {
          print("USER-INITIATED2 : \(Thread.current) : \(Task.currentPriority)")
        }
      }*/
      
      /*
      Task(priority: .high) {
        print("HIGH : \(Thread.current) : \(Task.currentPriority)")
        Task.detached { // If the child task not be connected with Parent Task , it should be written with anoth priority or as Task.detached
          print("DETACHED_FROM_HIGH : \(Thread.current) : \(Task.currentPriority)")
        }
      }
      */
      
      // How to cancel the Tasks
//      fetchImageTask =  Task {
//        await vm.fetchImage()
//      }
//    }
//    .onDisappear {
//      fetchImageTask?.cancel()
//    }
    .task {
      await vm.fetchImage()
    }
  }
}

#Preview {
  TaskBootcamp()
}
