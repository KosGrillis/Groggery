import UIKit

/// #FavouritesViewController
class FavouritesViewController: UIViewController {
    
    private var favouriteCocktails: [Cocktail] = []
    @IBOutlet var favouritesCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favourites"
        
        self.favouritesCollectionView.register(
            SwiftUiHostingCollectionViewCell<CollectionViewCocktailCell>.self,
            forCellWithReuseIdentifier: CollectionViewCocktailCell.IDENTIFIER
        )
        self.favouritesCollectionView.delegate = self
        self.favouritesCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.favouriteCocktails = FavouritesDataController.retrieveAll()
        self.favouritesCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case let cocktailDetailsViewController as CocktailDetailsViewController:
                guard let selectedCocktail = sender as? Cocktail else {
                    return assertionFailure("FavouritesSegueToCocktailDetails requires a sender of type Cocktail")
                }
                cocktailDetailsViewController.cocktailId = selectedCocktail.id
                cocktailDetailsViewController.cocktailName = selectedCocktail.name
                return
            default:
                break
        }
    }
}

class FavouritesCollectionViewSectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionHeaderLabel: UILabel!
}

extension FavouritesViewController: UICollectionViewDelegateFlowLayout {
    static var CELLS_PER_ROW: CGFloat = 2.0
    static var SECTION_INSETS = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    func calcCellSize() -> CGFloat {
        let padding = FavouritesViewController.SECTION_INSETS.left * (FavouritesViewController.CELLS_PER_ROW + 1)
        let availableWidth = self.view.frame.width - padding
        return availableWidth / FavouritesViewController.CELLS_PER_ROW
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCocktail = self.favouriteCocktails[indexPath.item]
        self.performSegue(withIdentifier: "FavouritesSegueToCocktailDetails", sender: selectedCocktail)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellWidthHeight = self.calcCellSize()
        return CGSize(width: cellWidthHeight, height: cellWidthHeight + CollectionViewCocktailCell.PADDING_BOTTOM)
    }
    
    func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if (self.favouriteCocktails.count > 1) {
            return FavouritesViewController.SECTION_INSETS
        }
        
        return UIEdgeInsets(
            top: FavouritesViewController.SECTION_INSETS.top,
            left: FavouritesViewController.SECTION_INSETS.left,
            bottom: FavouritesViewController.SECTION_INSETS.bottom,
            right: self.view.frame.width - calcCellSize() - FavouritesViewController.SECTION_INSETS.left
        )
    }
    
    func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return FavouritesViewController.SECTION_INSETS.left
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let id = "favouritesCollectionViewSectionHeader"
        let untypedSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath)

        guard let sectionHeader = untypedSectionHeader as? FavouritesCollectionViewSectionHeader else {
            return UICollectionReusableView()
        }
        
        sectionHeader.sectionHeaderLabel.text = "\(self.favouriteCocktails.count) saved cocktails"
        sectionHeader.sectionHeaderLabel.font = UIFont.preferredFont(forTextStyle: .footnote).fontWeightMedium()
        return sectionHeader
    }
}

extension FavouritesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favouriteCocktails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cocktailCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCocktailCell.IDENTIFIER, for: indexPath)
            as! SwiftUiHostingCollectionViewCell<CollectionViewCocktailCell>
        
        cocktailCell.host(
            CollectionViewCocktailCell(
                cocktail: self.favouriteCocktails[indexPath.item],
                parentWidth: self.calcCellSize()
            ),
            parent: self
        )
        
        return cocktailCell
    }
}
