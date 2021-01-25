import Foundation

struct SearchResults: Decodable {
    let items : [ItemsItem]?
}

struct ItemsItem : Decodable {
    let title : String?
}

extension SearchResults {
  static func initialData() -> SearchResults {
    guard
      let url = Bundle.main.url(forResource: "defaultResults", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        fatalError()
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(SearchResults.self, from: data)
    } catch {
      fatalError()
    }
  }
}
