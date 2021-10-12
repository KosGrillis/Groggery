import UIKit
import SwiftUI

/// #SearchResultsViewController
///
/// Receives searchQuery from HomeSearchViewController storyboard segue. From there is responsible for
/// communicating with CocktailDataController to fetch relevant Cocktails and then display them
class SearchResultsViewController: UIViewController {
    var searchQuery: String = ""
    var searchResults: [Cocktail]?
    private var cocktailDataController = CocktailDataController.sharedInstance
    
    var testMap: [String: TableViewCocktailCell] = [:]
    
    @IBOutlet var loadingIndicator: UIImageView!
    @IBOutlet var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsTableView.register(
            SwiftUiHostingTableViewCell<TableViewCountCell>.self,
            forCellReuseIdentifier: TableViewCountCell.IDENTIFIER
        )
        self.resultsTableView.register(
            SwiftUiHostingTableViewCell<TableViewCocktailCell>.self,
            forCellReuseIdentifier: TableViewCocktailCell.IDENTIFIER
        )
        self.resultsTableView.delegate = self
        self.resultsTableView.dataSource = self
        
        // In case we want to add a refresh control in the future:
        // let refreshControl = UIRefreshControl()
        // self.resultsTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "\"\(self.searchQuery)\""
        self.animateLoading()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.cocktailDataController.searchFor(query: self.searchQuery) { (results) in
            DispatchQueue.main.async {
                self.searchResults = results
                self.loadingIndicator.isHidden = true
                self.resultsTableView.reloadData()
            }
        }
    }
    
    private func animateLoading() {
        UIView.animate(
            withDuration: 0.185,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 15,
            options: [.autoreverse, .repeat],
            animations: {
                let rotationTransform = CGAffineTransform(rotationAngle: 0.2)
                let translationTransform = CGAffineTransform(translationX: 8, y: -10)
                self.loadingIndicator.transform = rotationTransform.concatenating(translationTransform)
            }
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case let cocktailDetailsViewController as CocktailDetailsViewController:
                guard let selectedCocktail = sender as? Cocktail else {
                    return assertionFailure("SearchResultsSegueToCocktailDetails requires a sender of type Cocktail")
                }
                cocktailDetailsViewController.cocktailId = selectedCocktail.id
                cocktailDetailsViewController.cocktailName = selectedCocktail.name
                return
            default:
                break
        }
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else {
            return
        }

        let selectedCocktail = self.searchResults![indexPath.section - 1]
        self.performSegue(withIdentifier: "SearchResultsSegueToCocktailDetails", sender: selectedCocktail)
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    static var ROW_ITEM_GAP = 16
    
    // Use sections instead of rows, so that we can add a "row" gap later
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let results = self.searchResults else { return 0 }
        return results.count + 1
    }

    // Set the header view background color to the background color of the background color of
    // its parent view (should be namedColor "Primer"), so that the header view acts as a row gap.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dummyViewHeight = CGFloat(SearchResultsViewController.ROW_ITEM_GAP)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.resultsTableView.bounds.size.width, height: dummyViewHeight))
        headerView.backgroundColor = nil
        return headerView
    }
    
    // Set the height of the row gap
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(SearchResultsViewController.ROW_ITEM_GAP)
    }

    // For all of the above to work, this should only ever return 1!!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countCell = tableView.dequeueReusableCell(withIdentifier: TableViewCountCell.IDENTIFIER)
            as! SwiftUiHostingTableViewCell<TableViewCountCell>
        let cocktailCell = tableView.dequeueReusableCell(withIdentifier: TableViewCocktailCell.IDENTIFIER)
            as! SwiftUiHostingTableViewCell<TableViewCocktailCell>
        
        countCell.contentView.backgroundColor = UIColor(named: "Primer")
        cocktailCell.contentView.backgroundColor = UIColor(named: "Primer")
        
        guard let results = self.searchResults, results.count + 1 >= indexPath.section else {
            return cocktailCell // Empty cell for empty case
        }
        
        if (indexPath.section == 0) {
            countCell.host(TableViewCountCell(count: results.count), parent: self)
            return countCell
        } else {
            cocktailCell.host(TableViewCocktailCell(cocktail: results[indexPath.section - 1]), parent: self)
            return cocktailCell
        }
    }
}
