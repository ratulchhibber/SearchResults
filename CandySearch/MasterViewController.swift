import UIKit
import Alamofire

class MasterViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  
  private var pullControl = UIRefreshControl()
  let initialResults = SearchResults.initialData()
  var filteredResults: SearchResults?
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Search Results"
    setupSearchController()
    setupRefreshControl()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

extension MasterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredResults?.items?.count ?? 0
    }
    return initialResults.items?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                             for: indexPath)
    let dataSource = isFiltering ? filteredResults?.items : initialResults.items
    cell.textLabel?.text = dataSource?[indexPath.row].title
    return cell
  }
}

extension MasterViewController {//UIRefreshControl
  
  private func setupRefreshControl() {
  //  pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
    tableView.refreshControl = pullControl
  }
  
  @objc private func refreshListData(_ sender: Any) {
    filteredResults = initialResults
    tableView.reloadData()
    self.pullControl.endRefreshing()
  }
}

extension MasterViewController: UISearchBarDelegate {
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//    filteredResults = initialResults
//    tableView.reloadData()
  }
}

extension MasterViewController {// UISearchController
  
  private func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.searchBar.delegate = self
    searchController.obscuresBackgroundDuringPresentation  = false
    searchController.searchBar.placeholder = "Enter search keyword"
    navigationItem.searchController = searchController
    definesPresentationContext = true// This ensures that searchBar does not remain on the viewController if user navigates to another viewController while the UISearchController is active
  }
  
  
  private var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  private var isFiltering: Bool {
    return searchController.isActive && !isSearchBarEmpty
  }
  
  func filterContentForSearchText(_ searchText: String) {
    if isSearchBarEmpty { return }
    
    //Herein we compare the search string and after 0.5 seconds if the search text remains constant - we assume the user has stopped writing - then we proceed to search forward
    Debounce<String>.input(searchText, comparedAgainst: self.searchController.searchBar.text ?? "") {_ in
        self.triggerSearch(for: searchText)
    }
    
//    filteredCandies = candies.filter({
//      return $0.name.lowercased().contains(searchText.lowercased())
//    })
//    tableView.reloadData()
  }
}

extension MasterViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchBarText = searchController.searchBar.text else {
      return
    }
    filterContentForSearchText(searchBarText)
  }
}

extension MasterViewController {
  
  func triggerSearch(for keyword: String) {
    
    let searchQuery = "https://www.googleapis.com/customsearch/v1?key=\(SearchAPI.key)&cx=\(SearchAPI.cxId)&q=\(keyword)"
    
    AF.request(searchQuery).responseDecodable(of: SearchResults.self) { response in
      switch response.result {
      case .success(let results):
        self.filteredResults = results
        self.tableView.reloadData()
      case let .failure(error):
        print(error)
      }
    }
  }
}
