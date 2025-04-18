//
// SendableProtocolBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 18/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

// SendableProtocol is declaring an object whether or not it is safe to send into an asynchronous context.
// Basically, if we want to send an object into an actor we should probably conform to Sendable.
actor CurrentUserManager {
  func updateDatabase(userInfo: MyUserInfo) { }
  func createDatabase(userInfo: MyClassUserInfo) { }
}

// As struct is Value Type and it is thread safe. So we can conform this struct to Sendable Protocol. That means, it is safe to send to actor (Thread safe). If property using mutable (var), then also it is thread safe and can use Sendable.
struct MyUserInfo: Sendable {
  let name: String
}

// But instead of struct, if we use class, ie Reference type, then it will throw an error. To make the class Sendable use the class as final. final class means, no other class inheriting this class.
// By this compiler knows that the class is final & it won't change. And also its properties uses let ie it is also constant. That means it will also not change. So it is safe to use Sendable.
// if this class having some mutable properties(using var) then to use Sendable protocol to actor and become thread safe, we have to use @unchecked before Sendable keyword. But this is very dangerous. By using @unchecked that doesn't mean it is sendable and thread safe. It simply means compiler will not check its status ie it is thread safe or not to use sendable to actor.
// Then the solution is make the class thread safe manually or use actors instead of class.
final class MyClassUserInfo: @unchecked Sendable {
  // let name: String
  private var name: String
  
  // Creating this class thread safe manually
  private let lock = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
  
  init(name: String) {
    self.name = name
  }
  
  func updateName(_ newName: String) {
    lock.async {
      self.name = newName
    }
  }
}

class SendableProtocolBootcampViewModel: ObservableObject {
  let manager = CurrentUserManager()
  
  func updateCurrentUserInfo() async {
    let info = MyUserInfo(name: "USER_INFO")
    let classInfo = MyClassUserInfo(name: "CLASS_USER_INFO")
    await manager.updateDatabase(userInfo: info)
    await manager.createDatabase(userInfo: classInfo)
  }
}

struct SendableProtocolBootcamp: View {
  @StateObject private var vm = SendableProtocolBootcampViewModel()
  
  var body: some View {
    Text("Hello, World!")
      .task {
        await vm.updateCurrentUserInfo()
      }
  }
}

#Preview {
  SendableProtocolBootcamp()
}
