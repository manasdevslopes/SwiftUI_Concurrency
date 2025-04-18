//
// ActorsBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 18/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    
// Go to Edit Scheme -> Toggle on Hand Sanitizer under Diagnostics in Run. then run again. This will show Data Race issue in logs if there are any.
import SwiftUI

// 1. What is the problem that actors are solving?
// - Data Race problem. It is when two different threads are accessing the same object in memory (HEAP)
// 2. How was this problem solved prior to actors ?
// 3. Actors can solve the problem!

// 1st by creating a class and observe the problem with Data Race Problem
class MyDataManager {
  static let instance = MyDataManager()
  private init() {}
  
  var data: [String] = []
  
  func getRandomData() -> String? {
    self.data.append(UUID().uuidString)
    print("Thread.current", Thread.current)
    return data.randomElement()
  }
}

// 2nd Part - Simulate the actual scenario to call something like API in background Thread with completionHandler
class MyDataManager1 {
  static let instance = MyDataManager1()
  private init() {}
  
  var data: [String] = []
  
  func getRandomData(completionhandler: @escaping (_ title: String?) -> ()) {
    self.data.append(UUID().uuidString)
    print("Thread.current", Thread.current)
    completionhandler(self.data.randomElement())
  }
}

// 2nd Part Only Same example - with solution - Thread safe Class. But without Actors.
class MyDataManager2 {
  static let instance = MyDataManager2()
  private init() {}
  
  var data: [String] = []
  private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
  
  func getRandomData(completionhandler: @escaping (_ title: String?) -> ()) {
    lock.async {
      self.data.append(UUID().uuidString)
      print("Thread.current", Thread.current)
      completionhandler(self.data.randomElement())
    }
  }
}

// 3rd Part - Solution With actors
// Inside actor everything is isolated.
actor MyActorDataManager {
  static let instance = MyActorDataManager()
  private init() {}
  
  var data: [String] = []
  
  func getRandomData() -> String? {
      self.data.append(UUID().uuidString)
      print("Thread.current", Thread.current)
      return self.data.randomElement()
  }
  
  // nonisolated
  nonisolated let myRandomText: String = "qwerty"
  nonisolated func getSavedData() -> String {
    return "New Data"
  }
}


struct HomeView: View {
  // let manager = MyDataManager.instance
  // let manager = MyDataManager1.instance
  // let manager = MyDataManager2.instance
  let manager = MyActorDataManager.instance
  @State private var text: String = ""
  let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
  
  var body: some View {
    ZStack {
      Color.gray.opacity(0.8).ignoresSafeArea()
      Text(text).font(.headline)
    }
    .onAppear {
      // As in actor everything is isolated, so to access it we have to use await.
      Task {
        await manager.data
      }
      // To avoid this, if some property or function need to be access directly then add nonisolated before that.
      let _ = manager.getSavedData()
      let _ = manager.myRandomText
    }
    .onReceive(timer) { _ in
      // 1st Part
      /*if let data = manager.getRandomData() {
        self.text = data
      }*/
      
      // 2nd Part - Simulate the actual scenario to call something like API in background Thread and moving back to Main to update UI
      /*DispatchQueue.global(qos: .background).async {
        manager.getRandomData { title in
          if let data = title {
            DispatchQueue.main.async {
              self.text = data
            }
          }
        }
      }
      */
      
      // 3rd part - with actors
      Task {
        if let data = await manager.getRandomData() {
          await MainActor.run {
            self.text = data
          }
        }
      }
    }
  }
}

struct BrowseView: View {
  // let manager = MyDataManager.instance
  // let manager = MyDataManager1.instance
  // let manager = MyDataManager2.instance
  let manager = MyActorDataManager.instance
  @State private var text: String = ""
  let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
  
  var body: some View {
    ZStack {
      Color.yellow.opacity(0.8).ignoresSafeArea()
      Text(text).font(.headline)
    }
    .onReceive(timer) { _ in
      // 1st Part
      /*if let data = manager.getRandomData() {
        self.text = data
      }*/
      
      // 2nd Part - Simulate the actual scenario to call something like API in background Thread and moving back to Main to update UI
      /*DispatchQueue.global(qos: .default).async {
        manager.getRandomData { title in
          if let data = title {
            DispatchQueue.main.async {
              self.text = data
            }
          }
        }
      }
      */
      
      // 3rd part - with actors
      Task {
        if let data = await manager.getRandomData() {
          await MainActor.run {
            self.text = data
          }
        }
      }
    }
  }
}

struct ActorsBootcamp: View {
    var body: some View {
      TabView {
        HomeView()
          .tabItem {
            Label("Home", systemImage: "house.fill")
          }
        
        BrowseView()
          .tabItem {
            Label("Browse", systemImage: "magnifyingglass")
          }
      }
    }
}

#Preview {
    ActorsBootcamp()
}
