//
// SearchableBootcamp.swift
// SwiftConcurrencyBootcamp
//
// Created by MANAS VIJAYWARGIYA on 14/04/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//

import Combine
import SwiftUI

// MARK: - Models
struct Restaurant: Identifiable, Hashable {
  let id: String
  let title: String
  let cuisine: CuisineOption
}

enum CuisineOption: String, Comparable {
  case indian, american, italian, japanese
  
  static func < (lhs: CuisineOption, rhs: CuisineOption) -> Bool {
    if lhs == .indian {
      return true
    } else if rhs == .indian {
      return false
    } else {
      return lhs.rawValue < rhs.rawValue
    }
  }
}

final class RestaurantManager {
  func getAllRestaurants() async throws -> [Restaurant] {
    [
      Restaurant(id: "1", title: "Pani Puri Palace", cuisine: .indian),
      Restaurant(id: "2", title: "Mac Donald's", cuisine: .american),
      Restaurant(id: "3", title: "Domino's", cuisine: .italian),
      Restaurant(id: "4", title: "Noodles Heaven", cuisine: .japanese)
    ]
  }
}

@MainActor
final class SearchableViewModel: ObservableObject {
  let manager = RestaurantManager()
  @Published private(set) var allRestaurants: [Restaurant] = []
  @Published private(set) var filteredRestaurants: [Restaurant] = []
  @Published var searchText: String = ""
  @Published var searchScope: SearchScopeOption = .all
  @Published private(set) var allSearchScopes: [SearchScopeOption] = []
  
  private var cancellables = Set<AnyCancellable>()
  
  var isSearching: Bool {
    !searchText.isEmpty
  }
  
  var showSearchSuggestion: Bool {
    searchText.count < 5
  }
  
  enum SearchScopeOption: Hashable {
    case all
    case cuisine(option: CuisineOption)
    
    var title: String {
      switch self {
        case .all:
          return "All"
        case .cuisine(let option):
          return option.rawValue.capitalized
      }
    }
  }
  
  init() {
    addSubscribers()
  }
  
  private func addSubscribers() {
    $searchText
      .combineLatest($searchScope)
      .debounce(for: 0.3, scheduler: DispatchQueue.main)
      .sink { [weak self] (searchText, searchScope) in
        self?.filteredRestaurants(searchText, searchScope)
      }
      .store(in: &cancellables)
  }
  
  private func filteredRestaurants(_ searchText: String, _ currentSearchScope: SearchScopeOption) {
    guard !searchText.isEmpty else {
      filteredRestaurants = []
      searchScope = .all
      return
    }
    
    // Filter on SearchScope
    var restaurantsInScope = allRestaurants
    switch currentSearchScope {
      case .all: break
      case .cuisine(let option):
        restaurantsInScope = allRestaurants.filter { $0.cuisine == option }
    }
    
    // Filter on SearchText
    let search = searchText.lowercased()
    filteredRestaurants = restaurantsInScope.filter({ restaurant in
      let titlesContaisSearch = restaurant.title.lowercased().contains(search)
      let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
      return titlesContaisSearch || cuisineContainsSearch
    })
  }
  
  func loadRestaurants() async {
    do {
      allRestaurants = try await manager.getAllRestaurants()
      
      let allCuisines = Set(allRestaurants.map { $0.cuisine }).sorted()
      allSearchScopes = [.all] + allCuisines.map { SearchScopeOption.cuisine(option: $0) }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func getSearchSuggestions() -> [String] {
    guard showSearchSuggestion else { return [] }
    
    var suggestions: [String] = []
    let search = self.searchText.lowercased()
    if search.contains("pa") {
      suggestions.append("Pani Puri Palace")
    }
    if search.contains("ma") {
      suggestions.append("Mac Donald's")
    }
    if search.contains("do") {
      suggestions.append("Domino's")
    }
    
    suggestions.append("Market")
    suggestions.append("Grocery")
    
    suggestions.append(CuisineOption.indian.rawValue.capitalized)
    suggestions.append(CuisineOption.american.rawValue.capitalized)
    
    return suggestions
  }
  
  func getRestaurantSuggestions() -> [Restaurant] {
    guard showSearchSuggestion else { return [] }
    
    var suggestions: [Restaurant] = []
    let search = searchText.lowercased()
    if search.contains("ind") {
      suggestions.append(contentsOf: allRestaurants.filter { $0.cuisine == .indian })
    }
    if search.contains("am") {
      suggestions.append(contentsOf: allRestaurants.filter { $0.cuisine == .american })
    }
    
    return suggestions
  }
}

struct SearchableBootcamp: View {
@StateObject private var vm = SearchableViewModel()
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          ForEach(vm.isSearching ? vm.filteredRestaurants : vm.allRestaurants) { restaurant in
            NavigationLink(value: restaurant) {
              RestautantRow(restaurant)
            }
          }
        }
        .padding()
        
        //SearchChildView()
      }
      .searchable(text: $vm.searchText, placement: .automatic, prompt: Text("Search Restaurants..."))
      .searchScopes($vm.searchScope, scopes: {
        ForEach(vm.allSearchScopes, id: \.self) { scope in
          Text(scope.title).tag(scope)
        }
      })
      .searchSuggestions({
        ForEach(vm.getSearchSuggestions(), id: \.self) { suggestion in
          Text(suggestion).searchCompletion(suggestion)
        }
        ForEach(vm.getRestaurantSuggestions(), id: \.self) { suggestion in
          NavigationLink(value: suggestion) {
            Text(suggestion.title)
          }
        }
      })
      .task {
        await vm.loadRestaurants()
      }
      .navigationTitle("Restaurants")
      .navigationDestination(for: Restaurant.self) { restaurant in
        Text(restaurant.title.uppercased())
      }
    }
  }
}

struct SearchChildView: View {
  @Environment(\.isSearching) private var isSearching
  
  var body: some View {
    Text("Child View is Searching: \(isSearching.description)")
  }
}

extension SearchableBootcamp {
  private func RestautantRow(_ restaurant: Restaurant) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(restaurant.title).font(.headline)
      Text(restaurant.cuisine.rawValue.capitalized).font(.caption)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.black.opacity(0.05))
    .tint(.primary)
  }
}

#Preview {
  SearchableBootcamp()
}
