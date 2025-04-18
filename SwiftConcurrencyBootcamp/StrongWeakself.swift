//
// StrongWeakself.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 18/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

final class StrongWeakselfDataService {
  func getData() async -> String {
    "Updated Data!"
  }
}

final class StrongWeakselfViewModel: ObservableObject {
  @Published var data: String = "Some Title!"
  let dataService = StrongWeakselfDataService()
  private var someTask: Task<(), Never>? = nil
  private var myTasks: [Task<(), Never>] = []
  
  /* This implies a Strong Reference between data of this class & dataService class .getData() */
  func updateData() {
    Task {
      data = await dataService.getData()
    }
  }
  
  /* This is also implies a Strong Reference between data of this class & dataService class .getData(). Exactly the same thing. */
  func updateData2() {
    Task {
      self.data = await dataService.getData()
    }
  }
  
  /* This is also a Strong Reference */
  func updateData3() {
    Task {[self] in
      self.data = await dataService.getData()
    }
  }
  
  /* This is weak reference. Manually managed...*/
  func updateData4() {
    Task { [weak self] in
      if let data = await self?.dataService.getData() {
        self?.data = data
      }
    }
  }
  
  /* We don't need to managed weak/strong becoz we can manage the Task! */
  func updateData5() {
    someTask = Task {
      self.data = await self.dataService.getData()
    }
  }
  
  /* We don't need to managed weak/strong becoz we can manage the Task! */
  func updateData6() {
    let task1 = Task {
      self.data = await self.dataService.getData()
    }
    myTasks.append(task1)
    let task2 = Task {
      self.data = await self.dataService.getData()
    }
    myTasks.append(task2)
  }
  
  /* Cancel all task at once */
  func cancelTasks() {
    someTask?.cancel()
    someTask = nil
    
    myTasks.forEach({ $0.cancel() })
    myTasks = []
  }
  
  /* We purposely do not cancel tasks to keep strong references*/
  func updateData7() {
    Task {
      self.data = await self.dataService.getData()
    }
    Task.detached {
      self.data = await self.dataService.getData()
    }
  }
  
  /* This is the perfect way, as we don't bother about Strong weak self. It will automatically be done. As in View, .task is being used */
  func updateData8() async {
    self.data = await self.dataService.getData()
  }
}

struct StrongWeakself: View {
  @StateObject private var vm = StrongWeakselfViewModel()
  
    var body: some View {
      Text(vm.data)
        .onAppear {
          vm.updateData()
          vm.updateData2()
          vm.updateData3()
          vm.updateData4()
          vm.updateData5()
          vm.updateData6()
          vm.updateData7()
        }
        .onDisappear {
          vm.cancelTasks()
        }
        .task {
          await vm.updateData8()
        }
    }
}

#Preview {
    StrongWeakself()
}
