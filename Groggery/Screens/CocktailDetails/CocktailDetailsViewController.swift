import UIKit

/// #CocktailDetailsViewController
///
/// Receives cocktail id and name from storyboard segue, either from SearchResultsViewController or FavouriesViewController.
/// From there is responsible for communicating with CocktailDataController to get more detailed data about the cocktail, then
/// displays it.
class CocktailDetailsViewController: UIViewController {
    private let SCREEN_BOTTOM_PADDING = 250
    private let INGREDIENT_CELL_HEIGHT = 28
    private let INGREDIENTS_HEADER_HEIGHT = 38
    
    var cocktailId: String! // Passed via prepare segue
    var cocktailName: String! // Passed via prepare segue
    var cocktailDetails: Cocktail? {
        didSet { self.updateUi() }
    }
        
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var placeholderImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tagsStackView: UIStackView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var instructionsTextLabel: UILabel!
    @IBOutlet var instructionsHeadingLabel: UILabel!
    @IBOutlet var ingredientsTableView: UITableView!
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    
    private var cocktailDataController = CocktailDataController.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage.colorForNavBar(color: .clear)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: .clear), for: .default)
        
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.ingredientsTableView.delegate = self
        self.ingredientsTableView.dataSource = self
        
        self.placeholderImageView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        self.placeholderImageView.layer.zPosition = -1
        self.placeholderImageView.setImage(UIImage(named: "cocktail1"), animated: false)
        
        self.cocktailDataController.requestBy(cocktailId: self.cocktailId) { cocktail in
            DispatchQueue.main.async {
                self.cocktailDetails = cocktail
            }
        }
        self.cocktailDataController.downloadImageFor(cocktailId: self.cocktailId) { imageData in
            DispatchQueue.main.async {
                self.imageView.setImage(UIImage(data: imageData))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage.colorForNavBar(color: UIColor(named: "EdgeHighlight")!)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor(named: "Base")!), for: .default)
    }
    
    private func updateUi() {
        guard let cocktailDetails = self.cocktailDetails else {
            return;
        }

        // Update heading
        self.nameLabel.text = cocktailDetails.name
        
        // Update add to favourites button
        let isFavourite = FavouritesDataController.isFavourite(cocktailId: cocktailDetails.id)
        self.favouriteButton.setImage(
            UIImage(
                systemName: isFavourite ? "star.fill" : "star",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)
            ),
            for: .normal
        )
        self.favouriteButton.tintColor = UIColor(named: isFavourite ? "AccentYellow" : "ButtonGrey")
        
        // Update tags
        self.tagsStackView.clearSubviews()
        for tag in cocktailDetails.tags {
            guard let text = tag else { continue }
            
            let tagLabel = UILabel()
            tagLabel.text = "  \(text)  "
            tagLabel.font = UIFont.systemFont(ofSize: 14)
            tagLabel.textColor = UIColor(named: "TextTertiary")
            tagLabel.backgroundColor = UIColor(named: "Base")
            tagLabel.layer.borderColor = UIColor(named: "BaseAlt")?.cgColor
            tagLabel.layer.borderWidth = 1
            tagLabel.layer.cornerRadius = 4
            tagLabel.layer.masksToBounds = true
                        
            self.tagsStackView.addArrangedSubview(tagLabel)
            
            NSLayoutConstraint.activate([
                tagLabel.heightAnchor.constraint(equalTo: self.tagsStackView.heightAnchor)
            ])
        }
        self.tagsStackView.leftAlignSubviews()
        
        // Update instructions
        self.instructionsTextLabel.text = cocktailDetails.instructions
        self.instructionsHeadingLabel.text = "Instructions"
        self.instructionsHeadingLabel.font = UIFont.preferredFont(forTextStyle: .body).fontWeightMedium()
        
        // Update ingredients table
        guard let ingredientsCount = self.cocktailDetails?.ingredientsTuples?.count else {
            return
        }
        let setTableHeight = CGFloat(ingredientsCount * self.INGREDIENT_CELL_HEIGHT + self.INGREDIENTS_HEADER_HEIGHT)
        self.ingredientsTableViewHeightConstraint.constant = setTableHeight
        self.ingredientsTableView.reloadData()
        
        // Update height of the scroll views embedded content view based on the known data
        // plus additional bottom padding. This ensures that the scroll view scrolls correctly
        if let instructionsTextHeight = self.instructionsTextLabel.estimateHeight() {
            self.contentViewHeightConstraint.constant = setTableHeight +
                                                        instructionsTextHeight +
                                                        self.imageView.bounds.size.height +
                                                        self.nameLabel.bounds.size.height +
                                                        CGFloat(self.SCREEN_BOTTOM_PADDING)
        }
    }
    
    @IBAction func onFavouriteButtonTouchUpInside(_ sender: UIButton) {
        guard let cocktailToSave = self.cocktailDetails else {
            return
        }
        
        if (FavouritesDataController.isFavourite(cocktailId: self.cocktailId)) {
            _ = FavouritesDataController.removeFromFavourites(cocktail: cocktailToSave)
        } else {
            _ = FavouritesDataController.addToFavourites(cocktail: cocktailToSave)
        }
        
        self.updateUi()
    }
}

extension CocktailDetailsViewController: UITableViewDelegate { }
extension CocktailDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let countIngredients = self.cocktailDetails?.ingredientsTuples?.count else {
            return 0
        }
        return countIngredients
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.INGREDIENT_CELL_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "Ingredients"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(self.INGREDIENTS_HEADER_HEIGHT)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailDetailsIngredientsTableCell", for: indexPath)

        cell.textLabel?.text = self.cocktailDetails?.ingredientsTuples?[indexPath.row].0
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        cell.detailTextLabel?.text = self.cocktailDetails?.ingredientsTuples?[indexPath.row].1
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .callout)

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let tableSectionHeader = view as? UITableViewHeaderFooterView else {
            return
        }
        
        tableSectionHeader.tintColor = UIColor(named: "Primer")
        tableSectionHeader.textLabel?.font = UIFont.preferredFont(forTextStyle: .body).fontWeightMedium()
        tableSectionHeader.textLabel?.textColor = UIColor(named: "TextStandard")
    }
}
